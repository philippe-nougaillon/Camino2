class AdminController < ApplicationController
  before_action :user_authorized?

  def stats
    @users = User.all.order(current_sign_in_at: :desc)
    @total_audit = Audited::Audit.all.count
    # Account.all.each do |account|
    #   # @total_audit += helpers.account_infos(account).first
    #   @total_lignes += helpers.account_infos(account).last
    # end

    @users = @users.page(params[:page]).per(30)
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
