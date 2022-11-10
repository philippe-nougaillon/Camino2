class DocumentsController < ApplicationController
  def index
    @logs = current_user.logs.documents.limit(50)
    todos_id = current_user.account.todos.pluck(:id)
    @documents = ActiveStorage::Attachment.where(record_type: "Todo")
                                          .where(record_id: todos_id)
                                          .order('created_at DESC')

    return if params[:search].blank?

    blobs_id = ActiveStorage::Blob.where("filename ILIKE ?", "%#{params[:search]}%").pluck(:id)
    @documents = @documents.where(blob_id: blobs_id)
    # @logs = @logs.where('logs.description ILIKE ?', "%#{params[:search]}%")
  end
end
