class AgendaController < ApplicationController
  layout :checkifmobile

  def checkifmobile
    return 'phone' if request.variant and request.variant.include?(:phone)

    'application'
  end

  def index
    @projects = current_user.projects.where('duedate is not null')
    @todos = current_user.todos.where('duedate is not null')
    @projects = @projects.where('name ILIKE ?', "%#{params[:search]}%") unless params[:search].blank?
  end
end
