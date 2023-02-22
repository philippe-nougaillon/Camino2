module Api
  module V1
    class Api::V1::TodosController < ActionController::Base
      skip_before_action :verify_authenticity_token

      def index
        todos = Account.find_by(slug: params[:slug]).todos
        unless params[:duedate] == "null"
          todos = todos.where(duedate: params[:duedate].to_date)
        end

        render json: {data: todos}
      end
    end
  end
end