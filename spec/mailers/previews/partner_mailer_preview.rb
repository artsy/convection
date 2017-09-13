class PartnerMailerPreview < ActionMailer::Preview
  def submission_digest
    PartnerMailer.submission_digest(submission_digest_mail_params)
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
      provenance: 'Inherited from my mother who got it from her father after he divorced from his second wife.',
      large_images: [
        OpenStruct.new(image_urls: { 'large' => 'http://foo1.jpg' }),
        OpenStruct.new(image_urls: { 'large' => 'http://foo2.jpg' }),
        OpenStruct.new(image_urls: { 'large' => 'http://foo3.jpg' }),
        OpenStruct.new(image_urls: { 'large' => 'http://foo4.jpg' }),
        OpenStruct.new(image_urls: { 'large' => 'http://foo5.jpg' }),
        OpenStruct.new(image_urls: { 'large' => 'http://foo6.jpg' }),
        OpenStruct.new(image_urls: { 'large' => 'http://foo7.jpg' })
      ]
    )
  end

  def submission_digest_mail_params
    {
      submissions: [
        submission_params,
        submission_params,
        submission_params
      ],
      partner_name: 'Phillips'
    }
  end
end
