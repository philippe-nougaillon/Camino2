class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:about]
  before_action :user_authorized?
  def about; end

  def dashboard
    @results = Hash.new
    @projects = current_user.projects
    return unless @projects.any?

    @todos = current_user.account.todos
    @projects = @projects.where('name ILIKE ?', "%#{params[:search]}%") unless params[:search].blank?

    @projects_start = current_user.account.projects.minimum(:created_at).to_date
    @projects_end = current_user.account.projects.maximum(:duedate)
    @todos_overdue = current_user.account.todos.undone.where("todos.duedate < ?", Date.today).count

    last_commit = current_user.account.todos.done.order(:updated_at).last
    @last_commit_picture = last_commit.user.avatar if last_commit && last_commit.user.avatar.attached?

    @results = current_user.account.todos.done.group("DATE(todos.updated_at), projects.name").count(:id)

    @account_projects = current_user.account.projects

    respond_to do |format|
      format.html do 
      end

      format.xls do
        book = ProjectsToXls.new(@account_projects).call
        file_contents = StringIO.new
        book.write file_contents # => Now file_contents contains the rendered file output
        filename = "#{current_user.account.name.humanize}_Répartition_charge_projets.xls"
        send_data file_contents.string.force_encoding('binary'), filename: filename 
      end
    end
  end

  private

  def user_authorized?
    authorize :pages
  end
end
