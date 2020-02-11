class AdminMailerPreview < ActionMailer::Preview
  def submission
    AdminMailer.submission(receipt_mail_params)
  end

  private

  def receipt_mail_params
    {
      submission: OpenStruct.new(id: '12', processed_images: []),
      artist: OpenStruct.new(id: 'artist_id', name: 'Andy Warhol'),
      user_detail:
        OpenStruct.new(id: 'high_bidder_id', email: 'themaninblack@yahoo.com'),
      user: OpenStruct.new(id: 'x', name: 'William Black')
    }
  end
end
