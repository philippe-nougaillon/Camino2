class AccountsController < ApplicationController
  before_action :set_account
  before_action :user_authorized?

  # skip_before_action :authorize, except: [:edit, :update, :destroy, :index, :show]


  # GET /accounts/1/edit
  def edit
  end

  # PATCH/PUT /accounts/1
  # PATCH/PUT /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to current_user, notice: 'Compte modifié.' }
        format.json { render :show, status: :ok, location: @table }
      else
        format.html { render :edit }
        format.json { render json: @table.errors, status: :unprocessable_entity }
      end
    end
  end

  def suppression_compte
  end

  def suppression_compte_do
    Notifier.with(account: @account, reason: params[:reason]).delete_account_notification.deliver_now

    @account.destroy

    current_user = nil

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_account
    @account = Account.find_by(slug: params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def account_params
    params.require(:account).permit(:name, :password, :password_confirmation, :sitename, :logo, :hostname,
                                    users_attributes: %i[id email name username password password_confirmation])
  end

  def user_authorized?
    authorize @account
  end
end
