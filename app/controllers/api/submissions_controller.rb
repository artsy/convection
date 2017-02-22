module Api
  class SubmissionsController < BaseController
    def create
      param! :user_id, String, required: true
      param! :artist_id, String, required: true

      submission = SubmissionService.create_submission(params)
      render json: submission.to_json, status: 201
    end
  end
end
