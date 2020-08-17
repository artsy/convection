# frozen_string_literal: true

class SubmissionMatch
  def self.find_all(params)
    new(params).find_all
  end

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def find_all
    submissions =
      Submission.not_deleted.where(query).includes(:user).order(order_by)
    submissions = submissions.search(term) if term
    submissions
  end

  private

  def term
    params[:term].presence
  end

  def query
    { state: params[:state].presence, user_id: params[:user].presence }.compact
  end

  def sorting_by_users?
    sort.include?('users')
  end

  def order_by
    if sorting_by_users?
      "#{sort} #{direction}, submissions.id desc"
    else
      "#{sort} #{direction}"
    end
  end

  def sort
    params[:sort].presence || 'id'
  end

  def direction
    params[:direction].presence || 'desc'
  end
end
