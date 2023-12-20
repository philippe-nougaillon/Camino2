class AdminController < ApplicationController
  before_action :user_authorized?

  def stats
    @accounts = Account.all.joins(:users).order('users.current_sign_in_at DESC')
    @accounts = @accounts.page(params[:page]).per(50)
  end

  def suppression_compte
    account = Account.find_by(slug: params[:account])
    account.destroy

    respond_to do |format|
      format.html { redirect_to admin_stats_path }
      format.json { head :no_content }
    end
  end

  private
    def user_authorized?
      authorize :admin
    end
end
