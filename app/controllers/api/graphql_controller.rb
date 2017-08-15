module Api
  class GraphqlController < BaseController
    before_action :require_authentication

    def execute
      result = RootSchema.execute(
        params[:query],
        variables: params[:variables],
        context: {
          current_application: current_app,
          current_user: current_user
        }
      )
      render json: result, status: 200
    end
  end
end
