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
    submissions = custom_filtered_submissions

    submissions =
      submissions.not_deleted.where(query).includes(:user).order(order_by)
    submissions = submissions.search(term) if term
    submissions
  end

  private

  def custom_filtered_submissions
    submissions = Submission
    submissions =
      submissions_assigned_without_accepted_offer(
        submissions
      ) if filtering_by_assigned_without_accepted_offer?
    submissions =
      submissions_approved_without_reviewed_or_accepted_offer(
        submissions
      ) if params[:state] == Submission::APPROVED
    submissions
  end

  def submissions_approved_without_reviewed_or_accepted_offer(submissions)
    submissions
      .joins(
        "LEFT OUTER JOIN offers on offers.submission_id = submissions.id AND offers.state IN ('#{Offer::ACCEPTED}', '#{Offer::REVIEW}')"
      )
      .distinct
      .where(offers: {submission_id: nil})
  end

  def submissions_assigned_without_accepted_offer(submissions)
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

    submissions.where(id: ids)
  end

  def term
    params[:term].presence
  end

  def query
    attributes = {
      state: params[:state].presence,
      user_id: params[:user].presence,
      artist_id: params[:artist].presence,
      category: params[:category].presence
    }.compact
    attributes.merge!(user_email: user_email) if filtering_by_user_email?
    attributes.merge!(assigned_to: assigned_to) if filtering_by_assigned_to?
    attributes.merge!(cataloguer: cataloguer) if filtering_by_cataloguer?
    attributes
  end

  def filtering_by_assigned_to?
    params.keys.map(&:to_sym).include?(:assigned_to) &&
      params[:assigned_to] != "all"
  end

  def filtering_by_cataloguer?
    params.keys.map(&:to_sym).include?(:cataloguer) &&
      params[:cataloguer] != "all"
  end

  def filtering_by_assigned_without_accepted_offer?
    filtering_by_assigned_to? && %w[accepted published].include?(params[:state])
  end

  def filtering_by_user_email?
    params[:user_email].presence && params[:user].blank?
  end

  def sorting_by_users?
    sort.include?("users")
  end

  def order_by
    if sorting_by_users?
      "#{sort} #{direction}, submissions.id desc"
    else
      "#{sort} #{direction}"
    end
  end

  def sort
    params[:sort].presence || "id"
  end

  def direction
    params[:direction].presence || "desc"
  end

  def assigned_to
    params[:assigned_to].presence
  end

  def cataloguer
    params[:cataloguer].presence
  end

  def user_email
    params[:user_email].presence
  end
end
