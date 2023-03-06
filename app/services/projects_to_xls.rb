class ProjectsToXls < ApplicationService
    require 'spreadsheet'
    attr_reader :projects
    private :projects

    def initialize(projects)
      @projects = projects
    end

    def call
      Spreadsheet.client_encoding = 'UTF-8'
    
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet name: @projects.name
      bold = Spreadsheet::Format.new :weight => :bold, :size => 11

      headers = %w{Projet TodoList Todo Assignée_à Charge_estimée(j) Charge_réelle(j)}

      sheet.row(0).concat headers
      sheet.row(0).default_format = bold
      
      index = 1

      @projects.each do |project|
        project.todolists.each do |todolist|
          todolist.todos.each do |todo|
            fields_to_export = [
                          todo.todolist.project.name,
                          todo.todolist.name,
                          todo.name, 
                          todo.user.name,
                          todo.charge_est,
                          todo.charge_reelle
                  ]
            sheet.row(index).replace fields_to_export
            index += 1
          end
        end
      end
      return book

    end

end