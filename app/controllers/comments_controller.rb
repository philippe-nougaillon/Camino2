class CommentsController < ApplicationController
  before_action :set_comment, only: %i[show edit update destroy]

  # GET /comments
  # GET /comments.json
  def index
    @user = current_user
    if params[:project_id].blank?
      @comments = @user.comments.order('created_at DESC')
    else
      @project = Project.friendly.find(params[:project_id])
      @comments = @project.comments.order('created_at DESC')
    end

    return if params[:search].blank?

    @comments = @comments.where('comments.texte ILIKE ?', "%#{params[:search]}%")
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = Comment.new(comment_params)

    if @comment.save
      @comment.log_changes(:comment, current_user.id)
      respond_to do |format|
        format.html do |variant|
          variant.phone { redirect_to edit_todo_path(@comment.todo) }
          variant.none { redirect_to edit_todo_path(@comment.todo), notice: 'Commentaire ajouté' }
        end
      end
    else
      render action: 'new'
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
