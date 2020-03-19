# frozen_string_literal: true

module Api
  class GraphqlController < BaseController
    def execute
      result =
        ConvectionSchema.execute(query, variables: variables, context: context)
      render json: result, status: :ok
    end

    private

    def query
      params[:query]
    end

    def variables
      params[:variables]
    end

    def context
      {
        current_application: current_app,
        current_user: current_user,
        current_user_roles: current_user_roles
      }
    end
  end
end
