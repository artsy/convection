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

    # only show submissions that lack an accepted offer when filtering by assignee plus published or accepted [CX-812]
    return submissions unless filtering_by_assigned_without_accepted_offer?

    submissions.filter do |s|
      s.partner_submissions.size.zero? ||
        s.partner_submissions.none? { |ps| ps.accepted_offer.present? }
    end
  end

  private

  def term
    params[:term].presence
  end

  def query
    attributes = {
      state: params[:state].presence, user_id: params[:user].presence
    }.compact
    attributes.merge!(assigned_to: assigned_to) if filtering_by_assigned_to?
    attributes
  end

  def filtering_by_assigned_to?
    params.keys.map(&:to_sym).include?(:assigned_to) &&
      params[:assigned_to] != 'all'
  end

  def filtering_by_assigned_without_accepted_offer?
    filtering_by_assigned_to? && %w[accepted published].include?(params[:state])
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

  def assigned_to
    params[:assigned_to].presence
  end
end
