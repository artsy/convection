class PartnerMailerPreview < ActionMailer::Preview
  def submission_digest_auction
    params = submission_digest_mail_params.merge(partner_name: 'Phillips', partner_type: 'Auction', email: 'foo@foo.com')
    PartnerMailer.submission_digest(params)
  end

  def submission_digest_gallery
    params = submission_digest_mail_params.merge(partner_name: 'Gagosian', partner_type: 'Gallery', email: 'foo@foo.com')
    PartnerMailer.submission_digest(params)
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
      medium: 'Since the late 1990s, KAWS has produced art toys to be circulated as global commodities. '\
              'By engaging directly with branding, production, and distribution, his toys compel their '\
              'collectors to consider what the commodity status of art objects is today. Seen here, the '\
              "\"Accomplice” characters from KAWS are appropriately branded with the artist's trademark \"X\" "\
              "to replace each of the figure's original eyes. The black example is from an edition of 500 "\
              'and the pink example is from an edition of 1000',
      artist_name: 'Damien Hirst',
      location_city: 'New York',
      location_state: 'NY',
      location_country: 'USA',
      provenance: 'Inherited from my mother who got it from her father after he divorced from his second wife.',
      edition_number: '12a',
      edition_size: 100,
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
      ]
    }
  end
end
