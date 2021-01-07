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
      if filtering_by_assigned_without_accepted_offer?
        submissions_assigned_without_accepted_offer
      else
        Submission
      end

    submissions =
      submissions.not_deleted.where(query).includes(:user).order(order_by)
    submissions = submissions.search(term) if term
    submissions
  end

  private

  def submissions_assigned_without_accepted_offer
    sql = <<SQL.squish
    WITH submissions_with_counts AS (
      SELECT s.id as submission_id,
             COUNT(DISTINCT ps.id) AS count_partner_submissions,
             COUNT(DISTINCT ps.accepted_offer_id) AS count_accepted_offers
      FROM submissions s
       LEFT JOIN partner_submissions ps on ps.submission_id = s.id
      GROUP BY 1
      )
      SELECT submission_id
      FROM submissions_with_counts
      WHERE count_partner_submissions = 0 OR count_accepted_offers = 0
SQL

    ids = ActiveRecord::Base.connection.select_all(sql).rows.flatten

    Submission.where(id: ids)
  end

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
