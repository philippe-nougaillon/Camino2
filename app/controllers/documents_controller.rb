class DocumentsController < ApplicationController
  def index
    @user = current_user
    @projects = @user.projects
    @logs = @user.logs.documents.limit(50)
    @documents = @user.account.todos.where('docname is not null').order('updated_at DESC').limit(9)

    return if params[:search].blank?

    @documents = @documents.where('docname ILIKE ?', "%#{params[:search]}%")
    @logs = @logs.where('logs.description ILIKE ?', "%#{params[:search]}%")
  end
end
