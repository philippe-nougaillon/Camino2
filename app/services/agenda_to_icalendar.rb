class AgendaToIcalendar < ApplicationService
  require 'icalendar'
  attr_reader :projects, :todos

  def initialize(projects, todos)
    @projects = projects
    @todos = todos
  end

  def call
    
    calendar = Icalendar::Calendar.new

    calendar.timezone do |t|
      t.tzid = "Europe/Paris"
    end
    
    projects.each do | p |
      event = Icalendar::Event.new
      event.dtstart = p.duedate.strftime("%Y%m%dT%H%M%S")
      # event.dtend = c.fin.strftime("%Y%m%dT%H%M%S")
      event.summary = p.name
      event.description = p.description
      # event.location = "BioPark #{c.salle.nom if c.salle}"
      # event.url = "https://planning.iae-paris.com/"
      calendar.add_event(event)
    end

    todos.each do | t |
      event = Icalendar::Event.new
      event.dtstart = t.duedate.strftime("%Y%m%dT%H%M%S")
      # event.dtend = c.fin.strftime("%Y%m%dT%H%M%S")
      event.summary = "#{t.project.name}:#{t.todolist.name}: #{t.name}"
      # event.description = t.description
      # event.location = "BioPark #{c.salle.nom if c.salle}"
      # event.url = "https://planning.iae-paris.com/"
      calendar.add_event(event)
    end
    return calendar.to_ical
  end
end