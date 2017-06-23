class NotificaitonService
  def self.post_submission_event(submission_id, action)
    submission = Submission.find(submission_id)
    # post notification
    event = Events::SubmissionEvent.new(action: action, model: submission)
    Artsy::EventService.post_event(topic: Events::SubmissionEvent::Topic, event: event)
  end
end
