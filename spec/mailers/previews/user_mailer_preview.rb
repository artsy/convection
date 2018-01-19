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

  def offer
    UserMailer.offer(
      offer: auction_offer,
      artist: OpenStruct.new(id: 'artist_id', name: 'Andy Warhol')
    )
  end

  private

  def receipt_mail_params
    {
      submission: base_submission,
      artist: OpenStruct.new(id: 'artist_id', name: 'Andy Warhol'),
      user_detail: OpenStruct.new(id: 'high_bidder_id', email: 'themaninblack@yahoo.com'),
      user: OpenStruct.new(id: 'x', name: 'William Black')
    }
  end

  def reminder_mail_params
    {
      submission: OpenStruct.new(id: '12'),
      user_detail: OpenStruct.new(id: 'high_bidder_id', email: 'themaninblack@yahoo.com'),
      user: OpenStruct.new(id: 'x', name: 'William Black')
    }
  end
end
