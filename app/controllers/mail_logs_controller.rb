class MailLogsController < ApplicationController
  before_action :user_authorized?

  # GET /mail_logs or /mail_logs.json
  def index
    mg_client = Mailgun::Client.new ENV["MAILGUN_API_KEY"], 'api.eu.mailgun.net'
    domain = ENV["MAILGUN_DOMAIN"]
    @result = mg_client.get("#{domain}/events", {:event => 'failed'}).to_h

    @mail_logs = current_user.account.mail_logs

    unless params[:to].blank?
      @mail_logs = @mail_logs.where("LOWER(mail_logs.to) like :search", {search: "%#{params[:to]}%".downcase})
    end

    @mail_logs = @mail_logs.page(params[:page]).per(20)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mail_log
      @mail_log = MailLog.find(params[:id])
    end

    def user_authorized?
      authorize MailLog
    end

end
