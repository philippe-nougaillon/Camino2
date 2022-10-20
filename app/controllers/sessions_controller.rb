# encoding: utf-8

class SessionsController < ApplicationController
  
  skip_before_action :authorize	

  def new
    if session[:user_id]
      redirect_to projects_path 
      return
    end

    if Account.where(hostname:request.host).any?
      @account = Account.find_by(hostname:request.host)
    else
      @account = nil
    end  

    respond_to do |format|
        format.html.phone 
        format.html.none 
    end
  end

  def create
  	user = User.find_by(username:params[:username])
  	if user and user.authenticate(params[:password]) 
  		session[:user_id] = user.id
      user.updated_at = DateTime.now
      user.save(validate: false)
      respond_to do |format|
        format.html.none { redirect_to projects_path }
        format.html.phone { redirect_to todos_path(user:user) } 
      end
  	else
  		redirect_to login_url, notice: "Utilisateur ou mot de passe incorrect"
  	end
  end

  def destroy
  	session[:user_id] = nil
  	redirect_to projects_path, notice: "Vous avez été déconnecté(e)..."
  end

end
