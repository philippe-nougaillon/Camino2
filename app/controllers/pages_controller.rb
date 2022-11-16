class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:about]
  before_action :user_authorized?
  def about; end

  def dashboard
    @projects = current_user.projects
    @todos = current_user.account.todos
    @projects = @projects.where('name ILIKE ?', "%#{params[:search]}%") unless params[:search].blank?

    @projects_start = current_user.account.projects.minimum(:created_at).to_date
    @projects_end = current_user.account.projects.maximum(:duedate)
    @todos_overdue = current_user.account.todos.undone.where("todos.duedate < ?", Date.today).count
    @last_commit_picture = current_user.account.todos.done.order(:updated_at).last.user.avatar

    @results = current_user.account.todos.done.group("DATE(todos.updated_at)").count(:id)
  end

  private

  def user_authorized?
    authorize :pages
  end
end
