class NotifierMailerPreview < ActionMailer::Preview
  def welcome_admin
    Notifier.welcome_admin(User.last)
  end
end