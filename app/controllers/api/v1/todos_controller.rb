module Api
  module V1
    class Api::V1::TodosController < ActionController::Base
      skip_before_action :verify_authenticity_token

      before_action :set_todo, only: %i[show]

      def index
        if !params[:slug].blank? && params[:slug] != "null"
          data = Account.find_by(slug: params[:slug]).todos
          if !params[:duedate].blank? && params[:duedate] != "null"
            data = data.where(duedate: params[:duedate].to_date)
          end
        elsif !params[:todo_slug].blank? && params[:todo_slug] != "null"
          todo = Todo.find_by(slug: params[:todo_slug])
          todolist = todo.todolist
          project = todolist.project

          data = todo << todolist + project
        else
          data = nil
        end

        render json: {data: data}
      end

      # def show
      #   todo = Todo.find_by(slug: params[:todo_slug])
      #   todolist = todo.todolist
      #   project = todolist.project

      #   data = todo.to_json + todolist.to_json + project.to_json

      #   render json: {data: data}
      # end
    end
  end
end