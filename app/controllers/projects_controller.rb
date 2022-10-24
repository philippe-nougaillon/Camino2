# encoding: utf-8

class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :save_as_template, :save_as_template_post, :invite, :send_invitation]
  before_action :tag_cloud
  
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
      @projects = @projects.where("name ILIKE ? OR description ILIKE ? OR memo ILIKE ?", "%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%")
      @logs = @logs.where("logs.description like ?", "%#{params[:search]}%")
      @comments = @comments.where("comments.texte like ?", "%#{params[:search]}%")
    end 

    unless params[:tag].blank?
      @projects = @projects.tagged_with(params[:tag])
      @logs = @logs.where(project_id:@projects.pluck(:id))
      @comments = @user.comments.joins(:project).where("projects.id in(?)", @projects.pluck(:id))
    end  

    @projects = @projects.uniq
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @todolist = Todolist.new
    @todolist.project_id = @project.id
    @logs = @project.logs.except_comments.limit(5)
    @comments = @project.comments.limit(5)
    @documents =  @project.todos.where("docname is not null")
    if @project.workflow == 1
      @todolists = @project.todolists.order(:row)
    else
      @todolists = @project.todolists.order(:name)
    end
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
    @account = current_user.account
    @templates = @account.templates
    @participants = @account.users
    @tables = @account.tables
  end

  # POST /projects
  # POST /projects.json
  def create
    unless params[:template_id].blank?
      @template = Template.find(params[:template_id])
      project_js = JSON.parse(@template.project)
      @project = Project.new(project_js.except('duedate'))
      # remplace le nom du modele par celui du nouveau projet
      @project.name = project_params[:name] if project_params[:name]
      @project.description = project_params[:description] if project_params[:description]
      #logger.debug "DEBUG #{@project.inspect}"
    else  
      @project = Project.new(project_params)
      @project.account_id = current_user.account_id
    end  

    if @project.valid?
        if Project.any?
          @project.id = Project.maximum(:id) + 1
        else
          @project.id = 1
        end
        @project.log_changes(:add, current_user.id)
        @project.save
        unless params[:template_id].blank? # ajoute les listes et tâches du modele
           to_except = ['id','done','duedate']
           JSON.parse(@template.participants).each do |p| 
              @project.participants.create(p.except('id'))
           end

           todolist_js = JSON.parse(@template.todolists)
           todo_js = JSON.parse(@template.todos)
 
           todolist_js.each do |todolist| 
              list_id = todolist['id']             
              @todolist = @project.todolists.create(todolist.except(*to_except))
              todo_js.each do |todo| 
                  todolist_id = todo['todolist_id']
                  if todolist_id == list_id  
                      @todolist.todos.create(todo.except(*to_except))
                  end
              end
            end
        else
          if params[:participants]
              params[:participants].each do |user_id| 
                @user = User.find(user_id)
                @project.participants.create(user_id:user_id)
                Log.create(project_id:@project.id, user_id:current_user.id, action_id:0, description:"ajouté le participant '#{@user.username}'")
                if params[:welcome_message]
                  Notifier.welcome_existing_user(@project, @user).deliver_later
                end
              end
          else
              # il faut au moins un participant (ici, le créateur du projet)
              @project.participants.create(user_id:current_user.id)
          end
        end
        redirect_to @project, notice: "Le projet '#{@project.name}' vient d'être ajouté"
    else   
       redirect_to @project, notice: "Une erreur est survenue: #{@project.errors.full_messages}..."
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      @project.attributes = project_params
      @project.log_changes(:edit, current_user.id)
      if @project.save(validates:false)
          if params[:participants]
            #logger.debug "DEBUG params_participants:#{params[:participants].inspect} class:#{params[:participants].class}"
            participants = @project.participants.pluck(:user_id).collect{|i| i.to_s }

            # ajout de participants ?
            diff = params[:participants] - participants
            diff.each do |participant_ajout_id|
              @project.participants.create(user_id:participant_ajout_id)
              Log.create(project_id:@project.id, user_id:current_user.id, action_id:1, 
                description:"ajouté le participant <b>#{User.find(participant_ajout_id).name}</b> au projet <a href='/projects/#{@project.id}'>#{@project.name}</a>")
            end  

            # suppression de participants ?
            diff = participants - params[:participants] 
            diff.each do |participant_supprime_id|
              @project.participants.find_by(user_id:participant_supprime_id).destroy
              Log.create(project_id:@project.id, user_id:current_user.id, action_id:1, 
                description:"enlevé le participant <b>#{User.find(participant_supprime_id).name}</b> au projet <a href='/projects/#{@project.id}'>#{@project.name}</a>")
            end  
       end
        format.html { redirect_to @project, notice: "Modifications projet enregistrées" }
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
    @project.log_changes(:delete, current_user.id)
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end

  def save_as_template

  end  

  def save_as_template_post
    unless params[:name].blank?
        # export projet + todolist + participants + todo to json files
        to_except = ['id','created_at', 'updated_at']
        project_js = @project.attributes.except(*to_except).to_json
        participants_js = @project.participants.to_json
        todolists_js = @project.todolists.to_json
        todos_js = @project.todos.to_json
        account_id = current_user.account_id
        Template.create(account_id:account_id, name:params[:name], project:project_js, participants:participants_js, todolists:todolists_js, todos:todos_js)
        redirect_to @project, notice:"Modèle '#{params[:name]}' créé avec succès"
    else    
        redirect_to action: :save_as_template, notice: "Merci de donner un nom à ce modèle !"
        return
    end
  end  

  def new_from_template

  end

  def invite
  end

  def send_invitation
    @project = Project.find(params[:id])
    unless params[:courriel].blank?
      if params[:client]

        # chercher le client dans user
        # si n'existe pas, on le crée
        # on l'ajoute comme participant au projet en lecture seule
        mail = params[:courriel]
        user = User.find_by(email:mail)
        unless user
          username = mail.split('@').first
          pass = random_password
          user = User.create(name:username, username:username, email:mail, password:pass, password_confirmation:pass, account: current_user.account)
        end  
        @project.participants.create(user_id:user.id, client:true)
      else
        @user = current_user
        Notifier.invite(@project, @user, params[:courriel]).deliver_later_now
        # ajoute à l'activité 
        Log.create(project_id:@project.id, user_id:@user.id, action_id:1, 
                  description:"invité le participant <b>#{params[:courriel]}</b> au projet '<a href='/projects/#{@project.id}'>#{@project.name}</a>'")
        flash[:notice] = "Invitation envoyée..."
      end  

    else
      flash[:notice] = "Veuillez entrer une adresse, svp..."
    end
    render action: 'invite'
  end

  # def accepter
  #   mail_invite = params[:q] 
  #   project = Project.find(params[:p]) 
  #   user_qui_invite = User.find(params[:u])

  #   unless User.find_by(email:mail_invite)
  #     # username = partie avant le @ du mail
  #     username = mail_invite.split('@').first
  #     # créer un mot de passe
  #     pass = random_password
  #     # créer un user
  #     user = User.create(name:username, username:username, email:mail_invite, password:pass, password_confirmation:pass,
  #                         account_id:user_qui_invite.account_id)
  #     # notifier par mail du mot de passe 
  #     Notifier.welcome(user, pass, project).deliver_later_now
  #     flash[:notice] = "Vos informations de connexion viennent d'être envoyées sur #{mail_invite} ..."
  #   else
  #     user = User.find_by(email:mail_invite)
  #   end  

  #   # ajouter le user comme un participant au projet
  #   unless project.participants.where(user_id:user.id).any? 
  #     project.participants.create(user_id:user.id)

  #     # ajoute à l'activité 
  #     Log.create(project_id:project.id, user_id:user_qui_invite.id, action_id:1, 
  #               description:"ajouté le participant <b>#{username}</b> au projet '<a href='/projects/#{project.id}'>#{project.name}</a>'")
    
  #     flash[:notice] = "participant ajouté..."  
  #   end  

  #   redirect_to projects_path   
  # end

  def tag_cloud
    #@tags = @projects.tag_counts_on(:tags)
  end

  def archive

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name, :description, :participants, :duedate, :workflow, :memo, :tag_list, :color, :table_id)
    end

    def random_password(size = 8)
      chars = (('A'..'Z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0)
      (1..size).collect{|a| chars[rand(chars.size)] }.join  
    end

end
