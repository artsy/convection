module Admin
  class SubmissionsController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Submission.
    #     page(params[:page]).
    #     per(10)
    # end

    def show
      submission = Submission.find(params[:id])
      user = Gravity.client.user(id: submission.user_id)._get
      artist = Gravity.client.artist(id: submission.artist_id)
      render locals: {
        page: Administrate::Page::Show.new(dashboard, requested_resource),
        artist_name: artist.name,
        user_name: user.name,
        user_email: user.user_detail.email
      }
    end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Submission.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
