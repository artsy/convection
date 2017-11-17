module Api
  class GraphqlController < BaseController
    def execute
      result = RootSchema.execute(
        params[:query],
        variables: params[:variables],
        context: {
          current_application: current_app,
          current_user: current_user,
          current_user_roles: current_user_roles
        },
        except: Util::PermissionBlacklist
      )
      render json: result, status: 200
    end
  end
end
