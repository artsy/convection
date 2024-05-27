class MyCollectionArtworkUpdatedService
  attr_accessor :submission, :subject, :object, :changes

  def initialize(payload)
    @submission = Submission.find(payload[:object][:submission_id])
    @subject = payload[:subject]
    @object = payload[:object]
    @changes = payload[:properties][:changes]
  end

  def notify_admin!
    return if ENV["ENABLE_MYC_ARTWORK_UPDATED_EMAIL"] != "true"

    if !submission.assigned_to
      Rails.logger.info("[MyCollectionArtworkUpdatedService] No admin assigned to the submission #{submission.id}.")
      return
    end

    if submission.state != "submitted"
      Rails.logger.info("[MyCollectionArtworkUpdatedService] Submission #{submission.id} is not in submitted state - skipping notification.")
      return
    end

    AdminMailer.artwork_updated(submission: submission, user_data: subject, artwork_data: object, changes: changes).deliver_now
  end
end
