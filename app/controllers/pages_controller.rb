class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:about]
  def about; end

  def dashboard
    @projects = current_user.projects
    @todos = current_user.todos
    @projects = @projects.where('name ILIKE ?', "%#{params[:search]}%") unless params[:search].blank?
  end
end
