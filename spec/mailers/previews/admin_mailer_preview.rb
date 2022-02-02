# frozen_string_literal: true

class AdminMailerPreview < ActionMailer::Preview
  def submission
    AdminMailer.submission(receipt_mail_params)
  end

  private

  def receipt_mail_params
    {
      submission:
        OpenStruct.new(
          id: '12',
          name: 'Michael Bluth',
          email: 'michael@bluth.com',
          processed_images: []
        ),
      artist: OpenStruct.new(id: 'artist_id', name: 'Andy Warhol'),
      user: OpenStruct.new(id: 'x', name: 'William Black')
    }
  end
end
