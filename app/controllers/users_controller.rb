class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]
  before_action :user_authorized?, except: %i[ show edit update destroy ]

  # GET /users or /users.json
  def index
    if params[:project_id].blank?
      @users = User.where(id: current_user.account.users)
    else
      @users = Project.find_by(slug: params[:project_id]).users
    end

    @users = @users.order('role DESC, name')
  end

  # GET /users/1 or /users/1.json
  def show
    authorize @user
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    authorize @user
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)
    @user.account = current_user.account

    respond_to do |format|
      if @user.save

        # notifier par mail le nouveau mot de passe
        Notifier.account_welcome_with_password(@user).deliver_now

        format.html { redirect_to users_path, notice: 'Utilisateur créé avec succès.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    authorize @user

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to user_url(@user), notice: 'Utilisateur modifié avec succès.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    authorize @user

    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url, notice: 'Utilisateur supprimé avec succès.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find_by(slug: params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:name, :username, :picturelink, :email, :password, :password_confirmation, :avatar)
  end

  def user_authorized?
    authorize User
  end
end
