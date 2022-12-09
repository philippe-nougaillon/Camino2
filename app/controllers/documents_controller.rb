class DocumentsController < ApplicationController
  def index
    @logs = current_user.logs.documents.limit(50)
    if current_user.admin?
      todos_id = current_user.account.todos.pluck(:id)
    else
      todos_id = current_user.todos.pluck(:id)
    end
    @documents = ActiveStorage::Attachment.where(record_type: "Todo")
                                          .where(record_id: todos_id)
                                          .order('created_at DESC')
                                          .order('created_at DESC')

    return if params[:search].blank?

    blobs_id = ActiveStorage::Blob.where("filename ILIKE ?", "%#{params[:search]}%").pluck(:id)
    @documents = @documents.where(blob_id: blobs_id)
    # @logs = @logs.where('logs.description ILIKE ?', "%#{params[:search]}%")
  end

  def purge
    document = ActiveStorage::Attachment.find(params[:id])
    todo = Todo.find(document.record_id)

    authorize todo

    todo.document.purge
    redirect_to documents_index_path, notice: "Document supprimé"
  end

end
