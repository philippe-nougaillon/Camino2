class DocumentsController < ApplicationController
  def index
    @user = current_user
    @projects = @user.projects
    @logs = @user.logs.documents.limit(50)
    todos_id = @user.account.todos.pluck(:id)
    @documents = ActiveStorage::Attachment.where(record_type: "Todo")
                                          .where(record_id: todos_id)
                                          .order('created_at DESC')

    return if params[:search].blank?

    @documents = @documents.where('docname ILIKE ?', "%#{params[:search]}%")
    @logs = @logs.where('logs.description ILIKE ?', "%#{params[:search]}%")
  end
end
