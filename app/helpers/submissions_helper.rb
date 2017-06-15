module SubmissionsHelper
  def formatted_location(submission)
    [submission.location_city, submission.location_state, submission.location_country].select(&:present?).join(', ')
  end

  def formatted_dimensions(submission)
    values = [submission.height, submission.width, submission.depth].select(&:present?)
    return if values.empty?
    "#{values.join(' x ')} #{submission.dimensions_metric.try(:downcase)}"
  end

  def formatted_category(submission)
    [submission.category, submission.medium].select(&:present?).join(', ')
  end
end
