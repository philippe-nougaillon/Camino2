class AgendaController < ApplicationController

  def index
    params[:calendar_type] ||= "month_calendar"
    @projects = current_user.projects.where('duedate is not null')
    @todos = current_user.todos.where('duedate is not null')
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
