class BasePreview < ActionMailer::Preview
  private

  def auction_offer
    OpenStruct.new(
      id: '123',
      offer_type: 'auction consignment',
      reference_id: '12345',
      currency: 'USD',
      rejection_reason: 'High shipping/marketing costs',
      rejection_note: 'Not my type either',
      low_estimate_cents: 12_300,
      high_estimate_cents: 15_000,
      notes: 'We would love to sell your work!',
      partner_submission: OpenStruct.new(
        partner: OpenStruct.new(id: 'partner_id', name: 'Gagosian Gallery')
      ),
      partner: OpenStruct.new(id: 'partner_id', name: 'Gagosian Gallery'),
      submission: base_submission
    )
  end

  def base_submission
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

  def base_submission_with_minimum_price
    s = base_submission
    s.minimum_price_cents = 50_000_00
    s.currency = 'USD'
    s.minimum_price_display = Money.new(s.minimum_price_cents, s.currency).format(no_cents: true)
    s
  end
end
