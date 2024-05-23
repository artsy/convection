# frozen_string_literal: true

class AdminMailerPreview < ActionMailer::Preview
  def submission
    AdminMailer.submission(**receipt_mail_params)
  end

  def artwork_updated
    AdminMailer.artwork_updated(**artwork_updated_params)
  end

  private

  def receipt_mail_params
    {
      submission:
        OpenStruct.new(
          id: "12",
          name: "Michael Bluth",
          email: "michael@bluth.com",
          processed_images: []
        ),
      artist: OpenStruct.new(id: "artist_id", name: "Andy Warhol"),
      user: OpenStruct.new(id: "x", name: "William Black")
    }
  end

  def artwork_updated_params
    submission = Submission.submitted.where.not(assigned_to: nil).last

    {
      submission: Submission.submitted.where.not(assigned_to: nil).last,
      user_data: {id: submission.user.gravity_user_id, email: submission.user_email},
      artwork_data: {id: submission.my_collection_artwork_id},
      changes: {
        title: ["Happy Cho", "Happy Choppers"],
        category: ["Photography", "Painting"],
        certificate_of_authenticity: [nil, true]
      }
    }
  end
end
