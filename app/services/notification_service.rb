class NotificationService
  class << self
    def post_submission_event(submission_id, action)
      submission = Submission.find(submission_id) # post notification
      event = SubmissionEvent.new(action: action, model: submission)
      Artsy::EventService.post_event(
        topic: SubmissionEvent::TOPIC, event: event
      )
    end
  end
end
