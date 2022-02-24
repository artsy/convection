# frozen_string_literal: true

class BrazeService
  class << self
    def send_swa_my_collection_email(submission_id)
      submission = Submission.find(submission_id)
      raise 'Still processing images.' unless submission.ready?

      raise 'User lacks email.' if submission.email.blank?

      recipient = [
        {
          external_user_id: submission.user.gravity_user_id,
          trigger_properties: {
            email_subject: '[TESTING] SWA Braze integration'
          }
        }
      ]
      braze_campaign_id = Convection.config.braze_campaign_id

      BrazeApi.trigger_campaign_send(braze_campaign_id, recipient)
    end
  end
end
