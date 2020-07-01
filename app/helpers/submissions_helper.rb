# frozen_string_literal: true

module SubmissionsHelper
  def formatted_score(score)
    (score || 0) * 100
  end

  def formatted_location(submission)
    [
      submission.location_city,
      submission.location_state,
      submission.location_country
    ].select(&:present?).join(', ')
  end

  def formatted_dimensions(submission)
    values =
      [submission.height, submission.width, submission.depth].select(&:present?)
    return if values.empty?

    "#{values.join('x')}#{submission.dimensions_metric.try(:downcase)}"
  end

  def formatted_category(submission)
    [submission.category, submission.medium].select(&:present?).join(', ')
  end

  def formatted_editions(submission)
    if submission.edition_number.present?
      "#{submission.edition_number}/#{submission.edition_size}"
    end
  end

  def formatted_medium_metadata(submission)
    edition_text =
      if formatted_editions(submission).present?
        "Edition #{formatted_editions(submission)}"
      end
    [
      submission.medium.try(:truncate, 100),
      formatted_dimensions(submission),
      edition_text
    ].compact.join(', ')
  end

  def reviewer_byline(submission)
    if submission.approved? || submission.published?
      "Approved by #{submission.reviewed_by_user.try(:name)}"
    elsif submission.rejected?
      "Rejected by #{submission.reviewed_by_user.try(:name)}"
    end
  end

  def formatted_date(date)
    date.strftime('%-m/%-d/%Y')
  end

  def preferred_image(submission)
    (
      submission.primary_image.presence ||
        submission.processed_images.min_by(&:id)
    ).image_urls[
      'square'
    ]
  end

  def formatted_current_time
    Time.now.in_time_zone('Eastern Time (US & Canada)').strftime(
      '%l:%M %Z %B %-d, %Y'
    )
  end

  def formatted_minimum_price(submission)
    if submission.minimum_price_cents.present?
      "Yes, #{submission.minimum_price_display}"
    else
      'No'
    end
  end

  def formatted_minimum_price_for_email(submission)
    if submission.minimum_price_cents.present?
      "Looking for: #{submission.minimum_price_display}"
    else
      ''
    end
  end

  def note_byline(note)
    return '' if note.created_at.blank?

    author = note.author&.to_hash || {}
    author_email = author['email']

    byline = (author_email ? "#{author_email} - " : 'User deleted - ')
    byline += 'Updated ' if note.created_at < note.updated_at
    byline +=
      note.updated_at.in_time_zone('Eastern Time (US & Canada)').to_formatted_s(
        :long
      )
    byline
  end
end
