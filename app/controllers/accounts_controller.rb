# encoding: utf-8

class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy]

  skip_before_action :authorize, except: [:edit, :update, :destroy, :index, :show]

  # GET /accounts
  # GET /accounts.json
  def index
    if current_user.id == 1
      @accounts = Account.joins(:users).order("users.updated_at DESC")
    else
      redirect_to root_url
    end
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
  end

  # GET /accounts/new
  def new
    @account = Account.new
    @account.users.build
  end

  # GET /accounts/1/edit
  def edit
    # Test si modifié par le propriétaire
    redirect_to root_url unless @account.users.first == @user
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @account = Account.new(account_params)

    respond_to do |format|
      if @account.save
        user = @account.users.last
        current_user.id = user.id 
        Notifier.account_welcome(@account, user).deliver_later

        format.html { redirect_to projects_path, notice: 'Bienvenue...' }
        format.json { render action: 'show', status: :created, location: @account }
      else
        format.html { render action: 'new' }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /accounts/1
  # PATCH/PUT /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to user_path(@account.users.first), notice: 'Compte modifié.' }
        format.json { render :show, status: :ok, location: @table }
      else
        format.html { render :edit }
        format.json { render json: @table.errors, status: :unprocessable_entity }
      end
    end

  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_params
      params.require(:account).permit(:name, :password, :password_confirmation, :sitename, :logo, :hostname, users_attributes: [:id, :email, :name, :username, :password, :password_confirmation])
    end
end
