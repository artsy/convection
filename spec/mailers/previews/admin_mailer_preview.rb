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
      artwork_data: {id: submission.my_collection_artwork_id},
      changes: {
        title: ["Happy Cho", "Happy Choppers"],
        category: ["Photography", "Painting"],
        certificate_of_authenticity: [nil, true]
      },
      image_added: {
        :square => "https://d32dm0rphc51dk.cloudfront.net/mr2x4lvjp1QycYooPibQjw/square.jpg",
        "large_rectangle" => "https://d32dm0rphc51dk.cloudfront.net/mr2x4lvjp1QycYooPibQjw/large_rectangle.jpg",
        "medium_rectangle" => "https://d32dm0rphc51dk.cloudfront.net/mr2x4lvjp1QycYooPibQjw/medium_rectangle.jpg",
        "small" => "https://d32dm0rphc51dk.cloudfront.net/mr2x4lvjp1QycYooPibQjw/small.jpg",
        "tall" => "https://d32dm0rphc51dk.cloudfront.net/mr2x4lvjp1QycYooPibQjw/tall.jpg",
        "large" => "https://d32dm0rphc51dk.cloudfront.net/mr2x4lvjp1QycYooPibQjw/large.jpg",
        "larger" => "https://d32dm0rphc51dk.cloudfront.net/mr2x4lvjp1QycYooPibQjw/larger.jpg",
        "normalized" => "https://d32dm0rphc51dk.cloudfront.net/mr2x4lvjp1QycYooPibQjw/normalized.jpg",
        "main" => "https://d32dm0rphc51dk.cloudfront.net/mr2x4lvjp1QycYooPibQjw/main.jpg",
        "medium" => "https://d32dm0rphc51dk.cloudfront.net/mr2x4lvjp1QycYooPibQjw/medium.jpg"
      }
    }
  end
end
