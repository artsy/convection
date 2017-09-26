class UserMailerPreview < ActionMailer::Preview
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

  private

  def receipt_mail_params
    {
      submission: OpenStruct.new(
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
        location_city: 'New York',
        location_state: 'NY',
        location_country: 'USA'
      ),
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
