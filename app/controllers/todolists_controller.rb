# encoding: utf-8

class TodolistsController < ApplicationController
  before_action :set_todolist, only: [:show, :edit, :update, :destroy]

  # GET /todolists
  # GET /todolists.json
  def index
    @todolists = Todolist.all
  end

  # GET /todolists/1
  # GET /todolists/1.json
  def show
    @todo = Todo.new
    @todo.todolist_id = @todolist.id
    @project = @todolist.project
  end

  # GET /todolists/new
  def new
    @todolist = Todolist.new
    @todolist.project_id = params[:project_id]
  end

  # GET /todolists/1/edit
  def edit
    if @todolist.project.workflow?
      # liste des indices avec nom de la todolist 
      @rows = []
      @todolists = @todolist.project.todolists.order(:row)
      (1..@todolists.count).each do |i|
        if @todolists.find_by(row:i)
            @rows << @todolists.find_by(row:i)
        else
            @rows << Todolist.new(row:i)
        end  
      end
    end 
     
  end

  # POST /todolists
  # POST /todolists.json
  def create
    @todolist = Todolist.new(todolist_params)

    if @todolist.project.workflow? # l'indice de la nouvelle liste est le maxi de toutes les listes +1
      if @todolist.project.todolists.any?
        @todolist.row = @todolist.project.todolists.maximum(:row) + 1
      else
        @todolist.row = 1
      end
    end  

    respond_to do |format|
      if @todolist.valid?
        if Todolist.any?
          @todolist.id = Todolist.maximum(:id) + 1
        else
          @todolist.id = 1
        end
        @todolist.log_changes(:add, current_user.id)
        @todolist.save
        format.html { redirect_to @todolist.project, notice: "'#{@todolist.name}' vient d'être ajouté au projet" }
        format.json { render action: 'show', status: :created, location: @todolist }
      else
        flash[:notice] = "Il manque un titre à cette liste..."
        format.html { redirect_to project_path(@todolist.project) }
        format.json { render json: @todolist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /todolists/1
  # PATCH/PUT /todolists/1.json
  def update
    @todolist.attributes = todolist_params
    @todolist.log_changes(:edit, current_user.id)

    if @todolist.project.workflow? and @todolist.changes.include?('row') 
      logger.debug "DEBUG! #{@todolist.changes}"
      row = @todolist.changes[:row]
      @todolist.project.todolists.find_by(row:row.last).update_attributes(row:row.first)
    end  

    respond_to do |format|
      if @todolist.save(validates:false)
        format.html { redirect_to @todolist.project, notice: "'#{@todolist.name}' vient d'être modifié" }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @todolist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /todolists/1
  # DELETE /todolists/1.json
  def destroy
    @project = @todolist.project
    @todolist.log_changes(:delete, current_user.id)
    @todolist.destroy
    respond_to do |format|
      format.html { redirect_to @project }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_todolist
      @todolist = Todolist.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def todolist_params
      params.require(:todolist).permit(:project_id, :name, :row, :duedate)
    end
end
