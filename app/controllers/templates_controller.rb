class TemplatesController < ApplicationController
  before_action :set_template, only: %i[show edit update destroy]
  before_action :user_authorized?, except: %i[ index new create ] 

  # GET /templates
  # GET /templates.json
  def index
    authorize Template
    @user = current_user
    @templates = @user.account.templates
  end

  # GET /templates/1
  # GET /templates/1.json
  def show; end

  # GET /templates/new
  def new
    authorize Template

    @template = Template.new
  end

  # GET /templates/1/edit
  def edit; end

  # POST /templates
  # POST /templates.json
  def create
    authorize Template

    @template = Template.new(template_params)

    respond_to do |format|
      if @template.save
        format.html { redirect_to @template, notice: 'Template was successfully created.' }
        format.json { render action: 'show', status: :created, location: @template }
      else
        format.html { render action: 'new' }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /templates/1
  # PATCH/PUT /templates/1.json
  def update
    respond_to do |format|
      if @template.update(template_params)
        format.html { redirect_to templates_url, notice: 'Modèle modifié avec succès' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /templates/1
  # DELETE /templates/1.json
  def destroy
    @template.destroy
    respond_to do |format|
      format.html { redirect_to templates_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_template
    @template = Template.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def template_params
    params.require(:template).permit(:name, :project, :participants, :todolists, :todos)
  end

  def user_authorized?
    authorize @template
  end
end
