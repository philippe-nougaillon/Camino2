class AgendaController < ApplicationController

  def index
    params[:calendar_type] ||= "month_calendar"
    if current_user.admin?
      @projects = current_user.account.projects.where('duedate is not null')
      @todos = current_user.account.todos.where('todos.duedate is not null')
    else
      @projects = current_user.projects.where('duedate is not null')
      @todos = current_user.todos.where('duedate is not null')
    end

    @user_projects = @projects.pluck(:name).uniq.sort
    if current_user.admin?
      @participants = current_user.account.users.pluck(:name).sort
      @todos = @todos.where(user_id: User.find_by(name: params[:participant]).id) unless params[:participant].blank?
    end

    unless params[:project].blank?
      @projects = @projects.where(name: params[:project])
      @todos = @todos.where(todolist_id: Project.find_by(name: params[:project]).todolists.pluck(:id))
    end

    @projects = @projects.where('name ILIKE ?', "%#{params[:search]}%") unless params[:search].blank?
    
    respond_to do |format|
      format.html
      
      format.ics do
        filename = "Camino_Agenda_iCal"
        response.headers['Content-Disposition'] = 'attachment; filename="' + filename + '.ics"'
        headers['Content-Type'] = "text/calendar; charset=UTF-8"
        render plain: AgendaToIcalendar.new(@projects, @todos).call
      end
    end
  end

  def export_icalendar
    @projects = current_user.projects.where('duedate is not null')
    @todos = current_user.todos.where('duedate is not null')
  end
end
