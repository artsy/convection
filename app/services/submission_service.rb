class SubmissionService
  Error = Class.new(StandardError)

  class << self
    def update_submission(submission, params)
      if params[:status] == 'submitted'
        if submission.status == 'submitted'
           raise Error.new('Already submitted.')
        else
          params.delete(:status)
          submission.update_attributes!(params)
          if submission.can_submit?
            submission.update_attributes!(status: 'submitted')
            delay.deliver_submission_receipt(submission.id)
            delay.deliver_submission(submission.id)
          else
            raise Error.new('Cannot submit.')
          end
        end
      else
        submission.update_attributes!(params)
      end
    end

    def deliver_submission_receipt(submission_id)
      submission = Submission.find(submission_id)
      raise 'Submission not found.' unless submission
      user = Gravity.client.user(id: submission.user_id)._get
      user_detail = user.user_detail._get
      raise 'User lacks email.' if user_detail.email.blank?
      artist = Gravity.client.artist(id: submission.artist_id)._get

      UserMailer.submission_receipt(
        submission: submission,
        user: user,
        user_detail: user_detail,
        artist: artist
      ).deliver_now
    end

    def deliver_submission(submission_id)
      submission = Submission.find(submission_id)
      raise 'Submission not found.' unless submission
      user = Gravity.client.user(id: submission.user_id)._get
      user_detail = user.user_detail._get
      artist = Gravity.client.artist(id: submission.artist_id)._get

      AdminMailer.submission(
        submission: submission,
        user: user,
        user_detail: user_detail,
        artist: artist
      ).deliver_now
    end
  end
end
