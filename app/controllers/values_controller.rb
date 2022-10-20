class ValuesController < ApplicationController
  before_action :set_value, only: [:show, :edit, :update, :destroy]

  # GET /values
  # GET /values.json
  def index
    @values = Value.all
  end

  # GET /values/1
  # GET /values/1.json
  def show
  end

  # GET /values/new
  def new
    @value = Value.new
  end

  # GET /values/1/edit
  def edit
  end

  # POST /values
  # POST /values.json
  def create
    @value = Value.new(value_params)

    respond_to do |format|
      if @value.save
        format.html { redirect_to @value, notice: 'Value was successfully created.' }
        format.json { render :show, status: :created, location: @value }
      else
        format.html { render :new }
        format.json { render json: @value.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /values/1
  # PATCH/PUT /values/1.json
  def update
    respond_to do |format|
      if @value.update(value_params)
        format.html { redirect_to @value, notice: 'Value was successfully updated.' }
        format.json { render :show, status: :ok, location: @value }
      else
        format.html { render :edit }
        format.json { render json: @value.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /values/1
  # DELETE /values/1.json
  def destroy
    @value.destroy
    respond_to do |format|
      format.html { redirect_to values_url, notice: 'Value was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_value
      @value = Value.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def value_params
      params.require(:value).permit(:field_id, :table_id, :data)
    end
end
