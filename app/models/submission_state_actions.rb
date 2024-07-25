# frozen_string_literal: true

class SubmissionStateActions
  def self.for(submission)
    new(submission).run
  end

  attr_reader :submission

  def initialize(submission)
    @submission = submission
  end

  def run
    case submission.state
    when Submission::DRAFT, Submission::SUBMITTED
      [approve_action, publish_action, hold_action, reject_action, close_action]
    when Submission::RESUBMITTED
      [publish_action, hold_action, reject_action, close_action]
    when Submission::APPROVED
      [publish_action, hold_action, close_action]
    when Submission::PUBLISHED
      [close_action]
    when Submission::HOLD
      [approve_action, publish_action, reject_action, close_action]
    else
      []
    end
  end

  private

  def default_classes
    ["btn btn-secondary btn-small btn-full-width"]
  end

  def approve_action
    {
      class: default_classes << "btn-approve",
      confirm:
        "No email will be sent to the consignor and this submission will be excluded from the digests.",
      state: "approved",
      text: "Approve without CMS"
    }
  end

  def publish_action
    {
      class: default_classes << "btn-approve",
      confirm:
        "An email will be sent to the consignor, letting them know that their submission will be sent to our partner network and this work will appear in the digests and CMS. This action cannot be undone.",
      state: "published",
      text: "Publish"
    }
  end

  def reject_action
    {
      class: default_classes << "btn-delete",
      confirm:
        "An email will be sent to the consignor, letting them know that we are not accepting their submission. This action cannot be undone.",
      state: "rejected",
      text: "Reject"
    }
  end

  def close_action
    {
      class: default_classes << "btn-delete",
      confirm: "No email will be sent.",
      state: "closed",
      text: "Close"
    }
  end

  def hold_action
    {
      class: default_classes << "btn-delete",
      confirm: "No email will be sent to the consignor.",
      state: "hold",
      text: "Hold"
    }
  end
end
