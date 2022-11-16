class TablesController < ApplicationController
  before_action :set_table, only: %i[show show_attrs fill fill_do edit update destroy delete_record]
  before_action :user_authorized?

  layout :checkifmobile

  def checkifmobile
    return 'phone' if request.variant and request.variant.include?(:phone)

    'application'
  end

  # GET /tables
  # GET /tables.json
  def index
    # test si l'utilisateur est le propriétaire du compte
    if current_user != current_user.account.users.first
      redirect_to root_path, notice: "Désolé mais vous n'êtes pas autorisé à afficher les tables..."
      return
    end
    @tables = current_user.account.tables
  end

  # GET /tables/1
  # GET /tables/1.json
  def show
    @values = if params[:search].blank?
                @table.values
              else
                @table.values.where('data ILIKE ?', "%#{params[:search].strip}%")
              end

    respond_to do |format|
      format.html
      format.xls do
        headers['Content-Disposition'] = "attachment; filename=\"#{@table.name}-#{l(DateTime.now, format: :compact)}\""
      end
    end
  end

  def show_attrs
    @field = Field.new(table_id: @table.id)
  end

  def fill
    @record_index = params[:record_index] || @table.record_index + 1

    @todo = Todo.find(params[:todo_id]) if params[:todo_id]

    respond_to do |format|
      format.html.phone
      format.html.none
    end
  end

  def fill_do
    @user = current_user
    data = params[:data]
    table = Table.find(params[:table_id])
    record_index = data.keys.first
    values = data[record_index.to_s]

    todo = if params[:todo_id].blank?
             Todo.new
           else
             Todo.find(params[:todo_id])
           end

    if values.values.select { |v| v.present? }.any? # test si tous les champs sont renseignés

      # modification = si données existent déjà, on les supprime pour pouvoir ajouter les données modifiées
      update = table.values.where(record_index:).any?

      if update
        created_at_date = table.values.where(record_index:).first.created_at
        table.values.where(record_index:).destroy_all
      end

      # ajout des données
      table.fields.each do |field|
        record = table.values.new(record_index:,
                                  field_id: field.id,
                                  todo_id: todo.id,
                                  data: values[field.id.to_s],
                                  user_id: @user.id,
                                  created_at: created_at_date)
        record.save
      end

      # incrémenter le nombre d'enregistrements
      table.update(record_index:) unless update

      flash[:notice] = "Enregistrement #{update ? 'modifié' : 'ajouté'}"
    else
      flash[:notice] = "L'enregistrement n'a pas été ajouté"
    end

    respond_to do |format|
      format.html.phone { redirect_to todo }
      format.html.none  do
        if params[:todo_id].blank?
          redirect_to table
        else
          redirect_to edit_todo_path(todo)
        end
      end
    end
  end

  def delete_record
    if params[:record_index]
      @table.values.where(record_index: params[:record_index]).destroy_all
      # @table.update_attributes(size:@table.size - 1)
    end

    redirect_to @table
  end

  # GET /tables/new
  def new
    @table = Table.new
  end

  # GET /tables/1/edit
  def edit; end

  # POST /tables
  # POST /tables.json
  def create
    @table = Table.new(table_params)
    @user = current_user
    @table.account = @user.account

    respond_to do |format|
      if @table.save
        format.html { redirect_to table_path(@table), notice: 'Table ajoutée.' }
        format.json { render :show, status: :created, location: @table }
      else
        format.html { render :new }
        format.json { render json: @table.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tables/1
  # PATCH/PUT /tables/1.json
  def update
    respond_to do |format|
      if @table.update(table_params)
        format.html { redirect_to table_path(@table, attrs: 1), notice: 'Table modifiée.' }
        format.json { render :show, status: :ok, location: @table }
      else
        format.html { render :edit }
        format.json { render json: @table.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tables/1
  # DELETE /tables/1.json
  def destroy
    @table.destroy
    respond_to do |format|
      format.html { redirect_to tables_url, notice: 'Table supprimée.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_table
    @table = Table.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def table_params
    params.require(:table).permit(:name, :record_index)
  end

  def user_authorized?
    authorize Table
  end
end
