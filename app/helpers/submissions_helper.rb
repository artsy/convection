module SubmissionsHelper
  def formatted_location(submission)
    [submission.location_city, submission.location_state, submission.location_country].select(&:present?).join(', ')
  end

  def formatted_dimensions(submission)
    values = [submission.height, submission.width, submission.depth].select(&:present?)
    return if values.empty?
    "#{values.join('x')}#{submission.dimensions_metric.try(:downcase)}"
  end

  def formatted_category(submission)
    [submission.category, submission.medium].select(&:present?).join(', ')
  end

  def formatted_editions(submission)
    submission.edition_number.present? ? "#{submission.edition_number}/#{submission.edition_size}" : nil
  end

  def reviewer_byline(submission)
    if submission.approved?
      "Approved by #{submission.reviewed_by_user.try(:name)}"
    elsif submission.rejected?
      "Rejected by #{submission.reviewed_by_user.try(:name)}"
    end
  end

  def formatted_date(date)
    date.strftime('%-m/%-d/%Y')
  end

  def preferred_image(submission)
    if submission.primary_image.present?
      submission.primary_image.image_urls['square']
    else
      submission.processed_images.first.image_urls['square']
    end
  end

  def formatted_current_time
    Time.now.in_time_zone('Eastern Time (US & Canada)').strftime('%l:%M %Z %B %-d, %Y')
  end
end
