class MyCollectionArtworkUpdatedService
  attr_accessor :submission, :object, :changes, :image_added

  def initialize(payload)
    @submission = Submission.find(payload[:object][:submission_id])
    @object = payload[:object]
    @changes = payload[:properties][:changes]
    @image_added = payload[:properties][:image_added]
  end

  def notify_admin!
    return unless Convection.config.enable_myc_artwork_updated_email

    if !submission.assigned_to
      Rails.logger.info("[MyCollectionArtworkUpdatedService] No admin assigned to the submission #{submission.id}.")
      return
    end

    if submission.state != "approved"
      Rails.logger.info("[MyCollectionArtworkUpdatedService] Submission #{submission.id} is not in submitted state - skipping notification.")
      return
    end

    AdminMailer.artwork_updated(submission: submission, artwork_data: object, changes: changes, image_added: image_added).deliver_now
  end
end
