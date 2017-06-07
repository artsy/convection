module Admin
  class SubmissionsController < Admin::ApplicationController
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
  end
end
