module Api
  module V1
    class Api::V1::TodosController < ActionController::Base
      skip_before_action :verify_authenticity_token

      def index
        if params[:id] != "null"
          todos = Todo.where(id: params[:id])
        else
          todos = Account.find_by(slug: params[:slug]).todos
          if params[:duedate] != "null"
            todos = todos.where(duedate: params[:duedate].to_date)
          end
        end

        render json: {data: todos}
      end
    end
  end
end