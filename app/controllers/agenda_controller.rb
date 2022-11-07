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
    @user = current_user
    @projects = @user.projects.where("duedate is not null")
    @todos = @user.todos.where("duedate is not null")
    unless params[:search].blank?
    	@projects = @projects.where("name ILIKE ?", "%#{ params[:search]}%")
    end
    respond_to do |format|
      format.html.none
      format.html.phone 
    end
  end

end
