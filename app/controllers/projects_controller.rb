class ProjectsController < ApplicationController
  before_action :set_project,
                only: %i[show edit update destroy save_as_template save_as_template_post invite ]
  before_action :user_authorized?, except: %i[ show edit update destroy invite invite_do ]

  # skip_before_action :authorize, only: :accepter

  # GET /projects
  # GET /projects.json
  def index
    @user = current_user
    @projects = @user.projects
    @logs = @user.logs.except_comments.limit(5)
    @comments = @user.comments.limit(5)
    @tags = @projects.tag_counts_on(:tags)

    unless params[:search].blank?
      @projects = @projects.where('name ILIKE ? OR description ILIKE ? OR memo ILIKE ?', "%#{params[:search]}%",
                                  "%#{params[:search]}%", "%#{params[:search]}%")
      @logs = @logs.where('logs.description ILIKE ?', "%#{params[:search]}%")
      @comments = @comments.where('comments.texte ILIKE ?', "%#{params[:search]}%")
    end

    unless params[:tag].blank?
      @projects = @projects.tagged_with(params[:tag])
      @logs = @logs.where(project_id: @projects.pluck(:id))
      @comments = @user.comments.joins(:project).where('projects.id in(?)', @projects.pluck(:id))
    end

    @projects = @projects.uniq
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    authorize @project

    session[:show_only_undone] ||= "no"
    @logs = @project.logs.except_comments.limit(5)
    @comments = @project.comments.limit(5)
    @todolists = if @project.workflow == 1
                   @project.todolists.order(:row)
                 else
                   @project.todolists.order(:name)
                 end

    unless params[:search].blank?
      @todolists = @todolists.joins(:todos)
                              .where('todolists.name ILIKE :search OR todos.name ILIKE :search', {search: "%#{params[:search]}%"})
    end

    params[:show_only_undone] ||= session[:show_only_undone]

    if params[:show_only_undone] == "yes"
      @todolists = @todolists.joins(:todos).where('todos.done IS FALSE')
    end

    session[:show_only_undone] = params[:show_only_undone]

    @todolists = @todolists.uniq
  end

  # GET /projects/new
  def new
    @project = Project.new
    @user = current_user
    @account = @user.account
    @templates = @account.templates
    @participants = @account.users
    @tables = @account.tables
  end

  # GET /projects/1/edit
  def edit
    authorize @project

    @account = current_user.account
    @templates = @account.templates
    @participants = @account.users
    @tables = @account.tables
  end

  # POST /projects
  # POST /projects.json
  def create
    if params[:template_id].blank?
      @project = Project.new(project_params)
      @project.account_id = current_user.account_id
      @project.save
      @project.participants.create(user_id: current_user.id)
      redirect_to @project, notice: "Le projet '#{@project.name}' vient d'être ajouté"
    else
      CreateProjetFromTemplate.new(params[:template_id], project_params[:name]).call 
      redirect_to projects_path, notice: "Le projet '#{ project_params[:name] }' vient d'être créé à partir d'un modèle"
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    authorize @project

    respond_to do |format|
      @project.attributes = project_params
      @project.log_changes(:edit, current_user.id)
      if @project.save(validates: false)
        if params[:participants]
          # logger.debug "DEBUG params_participants:#{params[:participants].inspect} class:#{params[:participants].class}"
          participants = @project.participants.pluck(:user_id).collect { |i| i.to_s }

          # ajout de participants ?
          diff = params[:participants] - participants
          diff.each do |participant_ajout_id|
            @project.participants.create(user_id: participant_ajout_id)
            Log.create(project_id: @project.id, user_id: current_user.id, action_id: 1,
                       description: "ajouté le participant <b>#{User.find(participant_ajout_id).name}</b> au projet <a href='/projects/#{@project.id}'>#{@project.name}</a>")
          end

          # suppression de participants ?
          diff = participants - params[:participants]
          diff.each do |participant_supprime_id|
            @project.participants.find_by(user_id: participant_supprime_id).destroy
            Log.create(project_id: @project.id, user_id: current_user.id, action_id: 1,
                       description: "enlevé le participant <b>#{User.find(participant_supprime_id).name}</b> au projet <a href='/projects/#{@project.id}'>#{@project.name}</a>")
          end
        end
        format.html { redirect_to @project, notice: 'Modifications projet enregistrées' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    authorize @project

    # @project.log_changes(:delete, current_user.id)
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_path, notice: "Projet supprimé" }
      format.json { head :no_content }
    end
  end

  def save_as_template; end

  def save_as_template_post
    if params[:name].blank?
      redirect_to action: :save_as_template, notice: 'Merci de donner un nom à ce modèle !'
      nil
    else
      # export projet + todolist + participants + todo to json files
      to_except = %w[id created_at updated_at]
      project_js = @project.attributes.except(*to_except).to_json
      participants_js = @project.participants.to_json
      todolists_js = @project.todolists.to_json
      todos_js = @project.todos.to_json
      account_id = current_user.account_id
      Template.create(account_id:, name: params[:name], project: project_js, participants: participants_js,
                      todolists: todolists_js, todos: todos_js)
      redirect_to @project, notice: "Modèle '#{params[:name]}' créé avec succès"
    end
  end

  def new_from_template; end

  def invite
    authorize @project

    @users = current_user.account.users
                          .where.not(id: current_user.id )
                          .where.not(id: @project.participants.pluck(:user_id) )
  end

  # Ajout 
  def invite_do
    @project = Project.find_by(slug: params[:id])
    authorize @project

    participant = @project.participants.create(user: User.find(params[:user_id]), client: false)

    Log.create(project_id: @project.id, user_id: current_user.id, action_id: 1,
              description: "invité le participant <b>#{participant.user.name}</b> au projet '<a href='/projects/#{@project.id}'>#{@project.name}</a>'")

    redirect_to invite_path(id:@project.slug), notice: "Participant ajouté"
    
    # if params[:courriel].blank?
    #   redirect_to invite_path(id:@project.slug), alert: 'Veuillez entrer une adresse'
    # elsif params[:client]
    #   mail = params[:courriel]
    #   user = User.find_by(email: mail)
    #   if user
    #     redirect_to invite_path(id:@project.slug), alert: 'Participant déjà ajouté'
    #   else
    #     participant = @project.participants.new(user: User.find_by(email: params[:courriel]), client: false)
    #     username = mail.split('@').first
    #     pass = random_password
    #     user = User.create(name: username, username:, email: mail, password: pass, password_confirmation: pass,
    #                        account: current_user.account)
    #   end
    #   @project.participants.create(user_id: user.id, client: true)
    #   redirect_to projects_path, notice: 'Invitation envoyée au client'

    # # chercher le client dans user
    # # si n'existe pas, on le crée
    # # on l'ajoute comme participant au projet en lecture seule
    # else
    #   participant = @project.participants.new(user: User.find_by(email: params[:courriel]), client: false)
    #   if participant.valid?
    #     participant.save
    #     Notifier.invite(@project, current_user, params[:courriel]).deliver_now
    #     # ajoute à l'activité
    #     Log.create(project_id: @project.id, user_id: current_user.id, action_id: 1,
    #               description: "invité le participant <b>#{params[:courriel]}</b> au projet '<a href='/projects/#{@project.id}'>#{@project.name}</a>'")
    #     redirect_to projects_path, notice: 'Invitation envoyée'
    #   else
    #     redirect_to invite_path(id:@project.slug), alert: 'Participant déjà ajouté'
    #   end
    # end
  end

  def accepter
    mail_invite = params[:q]
    project = Project.friendly.find(params[:p])
    user_qui_invite = User.find(params[:u])

    unless User.find_by(email:mail_invite)
      # username = partie avant le @ du mail
      username = mail_invite.split('@').first
      # créer un mot de passe
      pass = random_password
      # créer un user
      user = User.create(name:username, username:username, email:mail_invite, password:pass, password_confirmation:pass,
                          account_id:user_qui_invite.account_id)
      # notifier par mail du mot de passe
      mailer_response = Notifier.welcome(user, pass, project).deliver_now
      MailLog.create(account_id: current_user.account.id, message_id:mailer_response.message_id, to:user.email, subject: "Bienvenue.")
      flash[:notice] = "Vos informations de connexion viennent d'être envoyées sur #{mail_invite} ..."
    else
      user = User.find_by(email:mail_invite)
    end

    # ajouter le user comme un participant au projet
    unless project.participants.where(user_id:user.id).any?
      project.participants.create(user_id:user.id)

      # ajoute à l'activité
      Log.create(project_id:project.id, user_id:user_qui_invite.id, action_id:1,
                description:"ajouté le participant <b>#{username}</b> au projet '<a href='/projects/#{project.id}'>#{project.name}</a>'")

      flash[:notice] = "participant ajouté..."
    end

    redirect_to projects_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find_by(slug: params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(:name, :description, :participants, :duedate, :workflow, :memo, :tag_list,
                                    :color, :table_id)
  end

  def random_password(size = 8)
    chars = (('A'..'Z').to_a + ('0'..'9').to_a) - %w[i o 0 1 l 0]
    (1..size).collect { |_a| chars[rand(chars.size)] }.join
  end

  def user_authorized?
    authorize Project
  end
end
