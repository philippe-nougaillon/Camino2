class WeeklyNewsletter < ApplicationService
  attr_reader :account

  def initialize(account)
    @account = account
  end

  def call
    @account.projects.each do |project|
      if project.weekly_logs.any?
        project.participants.where(want_weeklynewsletter: true).each do |participant|
          # mailer_response = Notifier.weekly_newsletter(participant, project).deliver_now
          # MailLog.create(account_id: participant.user.account.id, message_id: mailer_response.message_id, to: participant.user.email, subject: "Weekly Newsletter")
        end
      end
    end
  end
end

