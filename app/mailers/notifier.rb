# encoding: utf-8

class Notifier < ApplicationMailer
  default from: '"Camino" <camino2@philnoug.com>'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.welcome.subject
  #

  def new_account_notification
    @account = params[:account]
    mail(to:"philippe.nougaillon@gmail.com, p-edacquet@hotmail.fr").tap do |message|
      message.mailgun_options = {
        "tag" => [@account.name, "new_account"]
      }
    end
  end

  def welcome(user, pass, project)
    @greeting = "Bienvenue"
    @user = user
    @password = pass
    @project = Project.friendly.find(project.id)

    mail(to:user.email, bcc:"philippe.nougaillon@gmail.com").tap do |message|
      message.mailgun_options = {
        "tag" => [@user.account.name, "welcome"]
      }
    end
  end

  def welcome_existing_user(project, user)
    @project = project
    @user = user

    mail(to:user.email).tap do |message|
      message.mailgun_options = {
        "tag" => [@user.account.name, "welcome_existing_user"]
      }
    end
  end

  def account_welcome(account, user)
    @greeting = "Bienvenue"
    @user = user
    @account = account

    mail(to:user.email, subject:"[Camino] Votre espace de projet '#{@account.name}' a été créé", bcc:"philippe.nougaillon@gmail.com").tap do |message|
      message.mailgun_options = {
        "tag" => [@account.name, "account_welcome"]
      }
    end
  end

  def account_welcome_with_password(user)
    @greeting = "Bienvenue"
    @user = user

    mail(to:user.email, subject:"[Camino] Votre espace de projet '#{user.account.name}' a été créé", bcc:"philippe.nougaillon@gmail.com").tap do |message|
      message.mailgun_options = {
        "tag" => [@user.account.name, "account_welcome_with_password"]
      }
    end
  end

  def invite(project, user, mail_invite)
    @mail_invite = mail_invite
    @project = project
    @user = user

    mail(to:mail_invite, subject:"Invitation à participer au projet '#{project.name}'").tap do |message|
      message.mailgun_options = {
        "tag" => [@user.account.name, "invite"]
      }
    end
  end

  def todo(todo)
    @todo = todo
    mail(to:@todo.user.email, subject:"Une nouvelle tâche '#{@todo.name}' vous a été assignée.").tap do |message|
      message.mailgun_options = {
        "tag" => [@todo.user.account.name, "todo"]
      }
    end
  end

  def next_todo(todo)
    @todo = todo
    mail(to:@todo.user.email, subject: "La tâche '#{@todo.name}' vous attend ;-)").tap do |message|
      message.mailgun_options = {
        "tag" => [@todo.user.account.name, "next_todo"]
      }
    end
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.update.subject
  #
  def update(log)
    @log = log
    project_name = "#{log.project.name}" 
    project_name += ":#{log.todolist.name}" if log.todolist

    mail(to:log.project.participants.notification_subcribers.joins(:user).pluck('users.email'), subject:"Notification projet '#{project_name}'").tap do |message|
      message.mailgun_options = {
        "tag" => [@log.user.account.name, "update"]
      }
    end
  end

  def update_client(log, participant)
    @log = log
    @user = participant.user
    project_name = "#{log.project.name}" 
    project_name += ":#{log.todolist.name}" if log.todolist

    mail(to:@user.email, subject:"[#{project_name}] #{@log.user.name} vous informe...").tap do |message|
      message.mailgun_options = {
        "tag" => [@user.account.name, "update_client"]
      }
    end
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.reminder.subject
  #

  def forgot_password(user, pass)
    @user = user
    @password = pass

    mail(to:user.email, subject: "Nouveau mot de passe").tap do |message|
      message.mailgun_options = {
        "tag" => [@user.account.name, "forgot_password"]
      }
    end
  end

  def todo_notifier(todo)
    @todo = todo
    @user = todo.user
    mail(to:todo.user.email, subject: "Tâche en approche").tap do |message|
      message.mailgun_options = {
        "tag" => [@user.account.name, "todo_notifier"]
      }
    end
  end

  def daily_newsletter(participant, project)
    @logs = project.daily_logs
    @project = project
    mail(to:participant.user.email, subject: "Daily newsletter").tap do |message|
      message.mailgun_options = {
        "tag" => [participant.user.account.name, "daily_newsletter"]
      }
    end
  end

  def weekly_newsletter(participant, project)
    @logs = project.weekly_logs
    @project = project
    mail(to:participant.user.email, subject: "Weekly newsletter").tap do |message|
      message.mailgun_options = {
        "tag" => [participant.user.account.name, "weekly_newsletter"]
      }
    end
  end

end
