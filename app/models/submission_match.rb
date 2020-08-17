# frozen_string_literal: true

class SubmissionMatch
  def self.find_all(params)
    matching_submissions = Submission.not_deleted

    if params[:term].present?
      matching_submissions = matching_submissions.search(params[:term])
    end

    if params[:state].present?
      matching_submissions = matching_submissions.where(state: params[:state])
    end

    if params[:user].present?
      matching_submissions = matching_submissions.where(user_id: params[:user])
    end

    sort = params[:sort].presence || 'id'
    direction = params[:direction].presence || 'desc'

    if sort.include?('users')
      matching_submissions.includes(:user).reorder(
        "#{sort} #{direction}, submissions.id desc"
      )
    else
      matching_submissions.reorder("#{sort} #{direction}")
    end
  end
end
