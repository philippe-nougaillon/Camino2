class AgendaController < ApplicationController
  layout :checkifmobile

  def checkifmobile
    return 'phone' if request.variant and request.variant.include?(:phone)

    'application'
  end

  def index
    @user = current_user
    @projects = @user.projects.where('duedate is not null')
    @todos = @user.todos.where('duedate is not null')
    @projects = @projects.where('name ILIKE ?', "%#{params[:search]}%") unless params[:search].blank?
    respond_to do |format|
      format.html.none
      format.html.phone
    end
  end
end
