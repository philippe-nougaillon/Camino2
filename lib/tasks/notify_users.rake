namespace :users do
  desc "Envoyer une notification des tâches en approche"
  task notify: :environment do
    Account.all.each do |account|
      NotifyUsers.new(account.todos).call
      puts "DEBUG Notify users for account ##{account.id}"
    end
  end
end