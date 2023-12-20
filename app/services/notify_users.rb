class NotifyUsers < ApplicationService
  attr_reader :todos

  def initialize(todos)
    @todos = todos
  end

  def call
    todos_ids = @todos.where.not(duedate: nil).select { |todo| (Date.today + todo.notifydays.days) == todo.duedate }
    @todos = @todos.where(id: todos_ids.pluck(:id))
    @todos.each do |todo|
      mailer_response = Notifier.todo_notifier(todo).deliver_now
      MailLog.create(account_id: todo.user.account.id, message_id: mailer_response.message_id, to: todo.user.email, subject: "Tâche en approche.")
    end
  end
end