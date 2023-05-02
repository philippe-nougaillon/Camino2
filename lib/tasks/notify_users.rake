namespace :users do
  desc "Envoyer une notification des tâches en approche"
  task notify: :environment do
    User.all.each do |user|
      todos = user.todos.where.not(duedate: nil).select { |todo| (Date.today + todo.notifydays.days) == todo.duedate }
      if todos.any?
        # mailer_response = Notifier.with(user: user, todos: todos).deliver_now
        # MailLog.create(account_id: user.account.id, message_id: mailer_response.message_id, to: user.email, subject: "Tâches en approche")
      end
    end
  end
end