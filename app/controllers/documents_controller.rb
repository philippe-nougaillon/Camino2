class DocumentsController < ApplicationController

  def index
  	user = User.find(session[:user_id])
    @projects = user.projects
    @logs = user.logs.documents.limit(50)
  	@documents = user.account.todos.where("docname is not null").order("updated_at DESC").limit(9)

	  unless params[:search].blank?
      @documents = @documents.where("docname like ?", "%#{params[:search]}%")
      @logs = @logs.where("logs.description like ?", "%#{params[:search]}%")
    end
  end

end
