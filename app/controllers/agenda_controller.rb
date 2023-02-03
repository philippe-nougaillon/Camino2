class AgendaController < ApplicationController

  def index
    params[:calendar_type] ||= "month_calendar"

    if current_user.admin?
      @projects = current_user.account.projects.where('duedate is not null')
      @todolists = current_user.account.todolists.where('todolists.duedate is not null')
      @todos = current_user.account.todos.where('todos.duedate is not null')
      @participants = current_user.account.users.pluck(:name).sort

      unless params[:participant].blank?
        @todos = @todos.where(user_id: User.find_by(name: params[:participant]).id)
      end
    else
      @projects = current_user.projects.where('duedate is not null')
      @todolists = Todolist.where(project_id: current_user.projects.pluck(:id)).where('todolists.duedate is not null')
      @todos = current_user.todos.where('duedate is not null')
    end

    @user_projects = @projects.pluck(:name).uniq.sort

    unless params[:project].blank?
      @projects = @projects.where(name: params[:project])
      @todolists = @todolists.where(project_id: Project.find_by(name: params[:project]).id)
      @todos = @todos.where(todolist_id: Project.find_by(name: params[:project]).todolists.pluck(:id))
    end
    
    @projects = @projects.where('name ILIKE ?', "%#{params[:search]}%") unless params[:search].blank?
  end
end
