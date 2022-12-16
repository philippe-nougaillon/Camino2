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
			project = Project.new(project_js.except('id','duedate','slug'))
			project.name = @new_project_name
			project.log_changes(:add, current_user.id)
			project.save

			participants_js.each do |p|
				project.participants.create(p.except('id','slug'))
			end
	
			todolist_js.each do |todolist|
				list_id = todolist['id']
				new_todolist = project.todolists.create(todolist.except('id', 'project_id', 'duedate', 'slug'))
				todo_js.each do |todo|
					todolist_id = todo['todolist_id']
					new_todolist.todos.create(todo.except('id','done','duedate','slug')) if todolist_id == list_id
				end
			end
		end
    end

end