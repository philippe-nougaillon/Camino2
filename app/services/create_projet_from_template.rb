class CreateProjetFromTemplate < ApplicationService
    attr_reader :template_id, :new_project_name
  
    def initialize(template_id, new_project_name)
    	@template = Template.find(template_id)
        @new_project_name = new_project_name
    end
  
    def call
        project_js = JSON.parse(@template.project)
		todolist_js = JSON.parse(@template.todolists)
		todo_js = JSON.parse(@template.todos)
		participants_js = JSON.parse(@template.participants)

		ActiveRecord::Base.transaction do
			new_project = Project.new(project_js.except('id','duedate','slug'))
			new_project.name = @new_project_name
			new_project.save

			participants_js.each do |p|
				new_project.participants.create(p.except('id','slug'))
			end
	
			todolist_js.each do |todolist|
				list_id = todolist['id']
				new_todolist = new_project.todolists.new(todolist.except('id', 'project_id', 'duedate', 'slug'))
				new_todolist.save
				todo_js.each do |todo|
					todolist_id = todo['todolist_id']
					new_todolist.todos.create(todo.except('id','done','duedate','slug')) if todolist_id == list_id
				end
			end
		end
    end

end