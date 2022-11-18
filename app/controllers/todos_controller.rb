class TodosController < ApplicationController
  before_action :set_todo, only: %i[show edit update destroy]
  before_action :user_authorized?, except: %i[ show edit update destroy ]

  layout :checkifmobile

  def checkifmobile
    return 'phone' if request.variant and request.variant.include?(:phone)

    'application'
  end

  # GET /todos
  # GET /todos.json
  def index
    params[:filter] ||= "all"

    if current_user.admin?
      @todos = Todo.joins(:todolist)
                    .where('todolists.project_id in (?)',current_user.projects.pluck(:id))
    else 
      @todos = current_user.todos
    end
    @todos = @todos.order('todos.duedate')

    @todos = @todos.tagged_with(params[:tag]) unless params[:tag].blank?
    @tags = @todos.tag_counts_on(:tags)

    case params[:filter]
    when "todo"
      @todos = @todos.undone

    when "pending"
      @todos = Todo.joins(:todolist).where('todolists.project_id in (?)',
                                    current_user.projects.pluck(:id)).undone

    when "notify"
      @todos = @todos.where.not(duedate: nil).select { |todo| (Date.today + todo.notifydays.days) == todo.duedate }
    end

    unless params[:search].blank?
      @todos = @todos.joins(:project, :todolist, :user).where(
        'todos.name ILIKE ? OR todolists.name ILIKE ? OR projects.name ILIKE ?', "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%"
      )
    end

    respond_to do |format|
      format.html do |variant|
        variant.phone
        variant.none
      end
    end
  end

  # GET /todos/1
  # GET /todos/1.json
  def show
    authorize @todo

    @comment = Comment.new
    @comment.todo_id = @todo.id
    @comment.user_id = @user.id
    @table = Table.find(@todo.project.table_id) if @todo.project.table_id

    respond_to do |format|
      format.html.phone
      format.html.none
    end
  end

  # GET /todos/new
  def new
    @todo = Todo.new
  end

  # GET /todos/1/edit
  def edit
    authorize @todo

    @project = @todo.project
    @user = current_user

    @comment = Comment.new
    # TODO: Améliorer le code
    @comment.todo_id = @todo.id
    @comment.user_id = @user.id

    @table = Table.find(@project.table_id) if @project.table_id
  end

  # POST /todos
  # POST /todos.json
  def create
    @todo = Todo.new(todo_params)

    respond_to do |format|
      if @todo.valid?
        @todo.id = if Todo.any?
                     Todo.maximum(:id) + 1
                   else
                     1
                   end
        @todo.log_changes(:add, current_user.id)
        @todo.save

        # sauvegarde le document
        # if params[:todo][:doc]
        #   uploaded_io = params[:todo][:doc]
        #   filename = Digest::SHA1.hexdigest('ElCaminoRealProject' + @todo.id.to_s) + File.extname(uploaded_io.original_filename)
        #   path = Rails.root.join('public', 'documents')
        #   File.open(path.join(uploaded_io.original_filename), 'wb') do |file|
        #     file.write(uploaded_io.read)
        #     @todo.docfilename = filename
        #     @todo.docname = uploaded_io.original_filename
        #     @todo.save
        #   end
        #   File.rename(path.join(uploaded_io.original_filename), path.join(filename))

        #   # création d'un aperçu pour les fichiers PDF
        #   if File.extname(@todo.docname) == '.pdf'
        #     require 'image_processing/mini_magick'

        #     processed = ImageProcessing::MiniMagick
        #                 .source(path.join(filename))
        #                 .loader(page: 0)
        #                 .resize_to_limit(330, 370)
        #                 .convert('png')
        #                 .call(destination: path.join(filename + '.png'))
        #   end

        #   @todo.log_changes(:document, current_user.id)
        # end


        # si ajout + done coché en même temps
        if todo_params[:done] == '1'
          @todo.update(done: false)
          @todo.done = true
          # logger.debug "DEBUG changes:#{@todo.changes}"
          @todo.log_changes(:edit, current_user.id)
          @todo.save
        elsif @todo.notify and @todo.user
          # envoyer notification au participant à qui cette tâche est assignée
          Notifier.todo(@todo).deliver_later
        end
        format.html { redirect_to @todo.todolist, notice: "La tâche '#{@todo.name}' vient d'être ajoutée" }
        format.json { render action: 'show', status: :created, location: @todo }
      else
        format.html { redirect_to @todo.todolist, alert: "Aucun changement n'a été enregistré" }
        format.json { render json: @todo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /todos/1
  # PATCH/PUT /todos/1.json
  def update
    authorize @todo

    @todo.attributes = todo_params
    @project = @todo.project

    if @project.workflow? and @todo.done? # si workflow linéraire, vérifie que la todo peut être terminée
      row = @todo.todolist.row

      # il n'y a pas de liste avant celle-là et liste précédente terminée ?
      if !(@project.todolists.minimum(:row) == row) && !@project.todolists.find_by(row: row - 1).done?
        redirect_to @todo.todolist,
                    notice: "Cette tâche ne peut pas être terminée pour l'instant (Workflow: linéaire)..."
        return
      end
    end

    @todo.log_changes(:edit, current_user.id)

    respond_to do |format|
      if @todo.save(validate: false)

        if @project.workflow? and @todo.done?
          # envoyer un mail pour prévenir d'une tâche à faire
          next_todo = @project.current_todolist.next_todo
          # logger.debug "DEBUG next_todo: #{next_todo.inspect}"
          Notifier.next_todo(next_todo).deliver_later if next_todo && next_todo.user
        end

        format.html { redirect_to @todo.todolist, notice: "La tâche '#{@todo.name}' vient d'être modifée" }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @todo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /todos/1
  # DELETE /todos/1.json
  def destroy
    authorize @todo

    @todolist = @todo.todolist
    @todo.log_changes(:delete, current_user.id)
    File.delete(Rails.root.join('public', 'documents', @todo.docfilename)) if @todo.docfilename
    @todo.destroy
    respond_to do |format|
      format.html { redirect_to @todolist, notice: 'To-do supprimée avec succès' }
      format.json { head :no_content }
    end
  end

  def close
    @todo = Todo.friendly.find(params[:id])
    @todo.done = true
    @todo.log_changes(:edit, current_user.id)
    @todo.save
    redirect_to @todo
  end

  def reopen
    @todo = Todo.friendly.find(params[:id])
    @todo.done = false
    @todo.log_changes(:edit, current_user.id)
    @todo.save
    redirect_to @todo
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_todo
    @todo = Todo.find_by(slug: params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def todo_params
    params.require(:todo).permit(:name, :todolist_id, :user_id, :done, :notify, :duedate, :document, :tag_list, :notifydays)
  end

  def user_authorized?
    authorize Todo
  end
end
