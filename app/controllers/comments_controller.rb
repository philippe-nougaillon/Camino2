class CommentsController < ApplicationController
  before_action :set_comment, only: %i[show edit update destroy]

  # GET /comments
  # GET /comments.json
  def index
    @user = current_user
    if params[:project_id].blank?
      @comments = @user.comments.order('created_at DESC')
    else
      @project = Project.find(params[:project_id])
      @comments = @project.comments.order('created_at DESC')
    end

    return if params[:search].blank?

    @comments = @comments.where('comments.texte ILIKE ?', "%#{params[:search]}%")
  end

  # GET /comments/1
  # GET /comments/1.json
  def show; end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit; end

  # POST /comments
  # POST /comments.json
  def create
    @comment = Comment.new(comment_params)

    respond_to do |format|
      if @comment.save
        @comment.log_changes(:comment, current_user.id)
        format.json { render action: 'show', status: :created, location: @comment }
        format.html do |variant|
          variant.phone { redirect_to todo_path(@comment.todo), notice: 'Commentaire ajouté' }
          variant.none { redirect_to edit_todo_path(@comment.todo), notice: 'Commentaire ajouté' }
        end
      else
        format.html { render action: 'new' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to comments_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    @comment = Comment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def comment_params
    params.require(:comment).permit(:todo_id, :user_id, :texte, :audience)
  end
end
