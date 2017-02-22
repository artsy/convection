class SubmissionService
  class << self
    def create_submission(params)
      submission = Submission.create!(submission_params(params))
      delay.deliver_submission_receipts(submission.id)
      submission
    end

    def deliver_submission_receipts(submission_id)
      submission = Submission.find(submission_id)
      raise 'Submission not found.' unless submission
      user = Gravity.client.user(id: submission.user_id)._get
      user_detail = user.user_detail._get
      raise 'User not found.' if user_detail.email.blank?
      artist = Gravity.client.artist(id: submission.artist_id)._get
      raise 'Artist not found.' if artist.name.blank?

      UserMailer.submission_receipt(
        submission: submission,
        user: user,
        user_detail: user_detail,
        artist: artist
      ).deliver_now

      AdminMailer.submission(
        submission: submission,
        user: user,
        user_detail: user_detail,
        artist: artist
      ).deliver_now
    end

    private

    def submission_params(params)
      params.permit(
        :user_id,
        :artist_id,
        :title,
        :medium,
        :year,
        :category,
        :height,
        :width,
        :depth,
        :dimensions_metric,
        :signature,
        :authenticity_certificate,
        :provenance,
        :location_city,
        :location_state,
        :location_country,
        :deadline_to_sell,
        :additional_info
      )
    end
  end
end
