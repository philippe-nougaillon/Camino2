namespace :newsletter do
  desc "Envoyer la daily newsletter"
  task daily: :environment do
    Account.all.each do |account|
      DailyNewsletter.new(account).call
      puts "DEBUG Daily Newsletter for account ##{account.id}"
    end
  end

  desc "Envoyer la weekly newsletter"
  task weekly: :environment do
    if Date.today.wday == 5
      Account.all.each do |account|
        WeeklyNewsletter.new(account).call
        puts "DEBUG Weekly Newsletter for account ##{account.id}"
      end
    end
  end
end