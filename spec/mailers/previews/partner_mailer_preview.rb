class PartnerMailerPreview < ActionMailer::Preview
  def submission_batch
    PartnerMailer.submission_batch(submission_batch_mail_params)
  end

  private

  def submission_params
    OpenStruct.new(
      id: '12',
      processed_images: [],
      images: [],
      title: 'My Favorite Artwork',
      year: 1992,
      height: 12,
      width: 14,
      dimensions_metric: 'in',
      category: 'Painting',
      medium: 'Oil on linen',
      artist_name: 'Damien Hirst',
      location_city: 'New York',
      location_state: 'NY',
      location_country: 'USA',
      provenance: 'Inherited from my mother who got it from her father after he divorced from his second wife.'
    )
  end

  def submission_batch_mail_params
    {
      submissions: [
        submission_params,
        submission_params,
        submission_params
      ],
      partner_name: 'Phillips',
      partner_emails: ['consign@phillips.com']
    }
  end
end
