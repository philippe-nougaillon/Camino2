class AgendaController < ApplicationController

  layout :checkifmobile

  def checkifmobile
    if request.variant and request.variant.include?(:phone) 
      return 'phone'  
    else
      return 'application'
    end
  end

  def index
    user = User.find(session[:user_id])
    @projects = user.projects.where("duedate is not null")
    @todos = user.todos.where("duedate is not null")
    unless params[:search].blank?
    	@projects = @projects.where("name like ?", "%#{ params[:search]}%")
    end
    respond_to do |format|
      format.html.none
      format.html.phone 
    end
  end

end
