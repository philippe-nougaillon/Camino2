# encoding: utf-8

class Notifier < ApplicationMailer
  default from: '"Camino" <camino@philnoug.com>'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.welcome.subject
  #

  def welcome(user, pass, project)
    @greeting = "Bienvenue"
    @user = user
    @password = pass
    @project = Project.find(project.id)

    mail(to:user.email, bcc:"philippe.nougaillon@gmail.com")
  end

  def welcome_existing_user(project, user)
    @project = project
    @user = user

    mail(to:user.email)
  end

  def account_welcome(account, user)
    @greeting = "Bienvenue"
    @user = user
    @account = account

    mail(to:user.email, subject:"[Camino] Votre espace de projet '#{@account.name}' a été créé", bcc:"philippe.nougaillon@gmail.com")
  end

  def account_welcome_with_password(account, user, password)
    @greeting = "Bienvenue"
    @user = user
    @account = account
    @password = password

    mail(to:user.email, subject:"[Camino] Votre espace de projet '#{@account.name}' a été créé", bcc:"philippe.nougaillon@gmail.com")
  end

  def invite(project, user, mail_invite)
    @mail_invite = mail_invite
    @project = project
    @user = user

    mail(to:mail_invite, subject:"Invitation à participer au projet '#{project.name}'")
  end  

  def todo(todo)
    @todo = todo
    mail(to:@todo.user.email, subject:"Une nouvelle tâche '#{@todo.name}' vous a été assignée.") 
  end  

  def next_todo(todo)
    @todo = todo
    mail(to:@todo.user.email, subject: "La tâche '#{@todo.name}' vous attend ;-)") 
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

    mail(to:log.project.participants.notification_subcribers.joins(:user).pluck('users.email'), subject:"Notification projet '#{project_name}'") 
  end

  def update_client(log, participant)
    @log = log
    @user = participant.user
    project_name = "#{log.project.name}" 
    project_name += ":#{log.todolist.name}" if log.todolist

    mail(to:@user.email, subject:"[#{project_name}] #{@log.user.name} vous informe...")
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.reminder.subject
  #

  def forgot_password(user, pass)
    @user = user
    @password = pass

    mail to: user.email
    mail subject: "Nouveau mot de passe" 
  end

end
