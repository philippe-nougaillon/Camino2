namespace :newsletter do
  desc "Envoyer la daily newsletter"
  task daily: :environment do
    User.all.each do |user|
      projects = Project.where(id: Participant.where(user_id: user.id, want_dailynewsletter: true).pluck(:project_id))
      logs = Log.where(project_id: projects.pluck(:id), created_at: 1.days.ago.to_date..Date.today)
      if logs.any?
        mailer_response = Notifier.with(user: user, projects: projects).daily_newsletter.deliver_now
        MailLog.create(account_id: user.account.id, message_id: mailer_response.message_id, to: user.email, subject: "Daily newsletter")
      end
    end
  end

  desc "Envoyer la weekly newsletter"
  task weekly: :environment do
    if Date.today.wday == 6
      User.all.each do |user|
        projects = Project.where(id: Participant.where(user_id: user.id, want_weeklynewsletter: true).pluck(:project_id))
        logs = Log.where(project_id: projects.pluck(:id), created_at: 7.days.ago.to_date..Date.today)
        if logs.any?
          mailer_response = Notifier.with(user: user, projects: projects).weekly_newsletter.deliver_now
          MailLog.create(account_id: user.account.id, message_id: mailer_response.message_id, to: user.email, subject: "Weekly newsletter")
        end
      end
    end
  end
end