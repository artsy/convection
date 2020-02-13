# frozen_string_literal: true

class UserMailerPreview < BasePreview
  def submission_receipt
    UserMailer.submission_receipt(receipt_mail_params)
  end

  def first_upload_reminder
    UserMailer.first_upload_reminder(reminder_mail_params)
  end

  def second_upload_reminder
    UserMailer.second_upload_reminder(reminder_mail_params)
  end

  def third_upload_reminder
    UserMailer.third_upload_reminder(reminder_mail_params)
  end

  def submission_approved
    UserMailer.submission_approved(receipt_mail_params)
  end

  def submission_rejected
    UserMailer.submission_rejected(receipt_mail_params)
  end

  def auction_consignment_offer
    UserMailer.offer(
      offer: auction_offer,
      artist: OpenStruct.new(id: 'artist_id', name: 'Andy Warhol'),
      user_detail:
        OpenStruct.new(id: 'high_bidder_id', email: 'themaninblack@yahoo.com'),
      user: OpenStruct.new(id: 'x', name: 'William Black')
    )
  end

  def retail_offer
    UserMailer.offer(
      offer:
        OpenStruct.new(
          id: '123',
          offer_type: 'retail',
          reference_id: '12345',
          currency: 'USD',
          rejection_reason: 'High shipping/marketing costs',
          price_cents: 12_300,
          commission_percent: 0.10,
          sale_period_start: Date.new(2_014, 1, 4),
          sale_period_end: Date.new(2_014, 10, 4),
          notes: 'We would love to sell your work!',
          partner_submission:
            OpenStruct.new(
              partner:
                OpenStruct.new(id: 'partner_id', name: 'Gagosian Gallery')
            ),
          partner: OpenStruct.new(id: 'partner_id', name: 'Gagosian Gallery'),
          submission: base_submission
        ),
      artist: OpenStruct.new(id: 'artist_id', name: 'Andy Warhol'),
      user_detail:
        OpenStruct.new(id: 'high_bidder_id', email: 'themaninblack@yahoo.com'),
      user: OpenStruct.new(id: 'x', name: 'William Black')
    )
  end

  def purchase_offer
    UserMailer.offer(
      offer:
        OpenStruct.new(
          id: '123',
          offer_type: 'purchase',
          reference_id: '12345',
          currency: 'USD',
          rejection_reason: 'High shipping/marketing costs',
          price_cents: 12_300,
          notes: 'We would love to sell your work!',
          partner_submission:
            OpenStruct.new(
              partner:
                OpenStruct.new(id: 'partner_id', name: 'Gagosian Gallery')
            ),
          partner: OpenStruct.new(id: 'partner_id', name: 'Gagosian Gallery'),
          submission: base_submission
        ),
      artist: OpenStruct.new(id: 'artist_id', name: 'Andy Warhol'),
      user_detail:
        OpenStruct.new(id: 'high_bidder_id', email: 'themaninblack@yahoo.com'),
      user: OpenStruct.new(id: 'x', name: 'William Black')
    )
  end

  def net_price_offer
    UserMailer.offer(
      offer:
        OpenStruct.new(
          id: '123',
          offer_type: 'net price',
          reference_id: '12345',
          currency: 'USD',
          sale_period_start: Date.new(2_014, 1, 4),
          sale_period_end: Date.new(2_014, 10, 4),
          rejection_reason: 'High shipping/marketing costs',
          price_cents: 12_300,
          notes: 'We would love to sell your work!',
          partner_submission:
            OpenStruct.new(
              partner:
                OpenStruct.new(id: 'partner_id', name: 'Gagosian Gallery')
            ),
          partner: OpenStruct.new(id: 'partner_id', name: 'Gagosian Gallery'),
          submission: base_submission
        ),
      artist: OpenStruct.new(id: 'artist_id', name: 'Andy Warhol'),
      user_detail:
        OpenStruct.new(id: 'high_bidder_id', email: 'themaninblack@yahoo.com'),
      user: OpenStruct.new(id: 'x', name: 'William Black')
    )
  end

  private

  def receipt_mail_params
    {
      submission: base_submission,
      artist: OpenStruct.new(id: 'artist_id', name: 'Andy Warhol'),
      user_detail:
        OpenStruct.new(id: 'high_bidder_id', email: 'themaninblack@yahoo.com'),
      user: OpenStruct.new(id: 'x', name: 'William Black')
    }
  end

  def reminder_mail_params
    {
      submission: OpenStruct.new(id: '12'),
      user_detail:
        OpenStruct.new(id: 'high_bidder_id', email: 'themaninblack@yahoo.com'),
      user: OpenStruct.new(id: 'x', name: 'William Black')
    }
  end
end
