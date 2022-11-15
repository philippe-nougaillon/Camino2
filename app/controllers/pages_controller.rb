class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:about]
  def about; end

  def dashboard
    @projects = current_user.projects
    @todos = current_user.account.todos
    @projects = @projects.where('name ILIKE ?', "%#{params[:search]}%") unless params[:search].blank?

    @results = current_user.account.todos.done.group("DATE(todos.updated_at)").count(:id)
  end
end
