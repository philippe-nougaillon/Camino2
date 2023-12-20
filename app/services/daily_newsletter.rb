class DailyNewsletter < ApplicationService
  attr_reader :account

  def initialize(account)
    @account = account
  end

  def call
    @account.projects.each do |project|
      if project.daily_logs.any?
        project.participants.where(want_dailynewsletter: true).each do |participant|
          mailer_response = Notifier.daily_newsletter(participant, project).deliver_now
          MailLog.create(account_id: participant.user.account.id, message_id: mailer_response.message_id, to: participant.user.email, subject: "Daily Newsletter")
        end
      end
    end
  end
end

