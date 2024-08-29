# frozen_string_literal: true

class UserMailer < ApplicationMailer
  helper :url, :submissions, :offers

  def submission_receipt(submission:, artist:)
    @submission = submission
    @artist = artist

    @utm_params =
      utm_params(
        source: "sendgrid",
        campaign: "sell",
        term: "cx",
        content: "received"
      )

    smtpapi category: %w[submission_receipt],
            unique_args: {
              submission_id: submission.id
            }
    mail(
      to: submission.email,
      subject: "Thank you for submitting your artwork to Artsy",
      bcc: Convection.config.bcc_email_address
    )
  end

  def first_upload_reminder(submission:)
    @submission = submission
    @utm_params =
      utm_params(
        source: "drip-consignment-reminder-e01",
        campaign: "consignment-complete"
      )

    smtpapi category: %w[first_upload_reminder],
            unique_args: {
              submission_id: submission.id
            }
    mail to: submission.email, subject: "You're Almost Done"
  end

  def second_upload_reminder(submission:)
    @submission = submission
    @utm_params =
      utm_params(
        source: "drip-consignment-reminder-e02-v2",
        campaign: "consignment-complete"
      )

    smtpapi category: %w[second_upload_reminder],
            unique_args: {
              submission_id: submission.id
            }
    mail to: submission.email,
         subject: "Artsy Consignments - complete your submission"
  end

  def submission_approved(submission:, artist:)
    @submission = submission
    @artist = artist
    @utm_params =
      utm_params(
        source: "sendgrid",
        campaign: "sell",
        term: "cx",
        content: "approved"
      )

    @tier_2_template_enabled = Convection.unleash.enabled?(
      "onyx-collector-submission-approved-tier-2-email",
      Unleash::Context.new(user_id: submission&.user&.gravity_user_id.to_s)
    )

    smtpapi category: %w[submission_approved],
            unique_args: {
              submission_id: submission.id
            }
    mail(
      to: submission.email,
      subject: "Artsy Approved Submission | Next Steps"
    )
  end

  def artist_submission_rejected(submission:, artist:)
    @submission = submission
    @artist = artist
    @utm_params =
      utm_params(
        source: "sendgrid",
        campaign: "sell",
        term: "cx",
        content: "artist-sub-rejection"
      )

    smtpapi category: %w[artist_submission_rejected],
            unique_args: {
              submission_id: submission.id
            }
    mail(to: submission.email, subject: "An update about your submission")
  end

  def fake_submission_rejected(submission:, artist:)
    @submission = submission
    @artist = artist
    @utm_params =
      utm_params(
        source: "sendgrid",
        campaign: "sell",
        term: "cx",
        content: "fake-rejection"
      )

    smtpapi category: %w[fake_submission_rejected],
            unique_args: {
              submission_id: submission.id
            }
    mail(to: submission.email, subject: "Artsy Submission")
  end

  def nsv_bsv_submission_rejected(submission:, artist:, logged_in:)
    @submission = submission
    @artist = artist
    @logged_in = logged_in

    @utm_params =
      utm_params(
        source: "sendgrid",
        campaign: "sell",
        term: "cx",
        content: "nsv-bsv-rejected"
      )

    smtpapi category: %w[nsv_bsv_submission_rejected],
            unique_args: {
              submission_id: submission.id
            }
    title = submission.title || "Unknown"
    artist_name = artist&.name
    subject = "Update on \"#{title}\" #{artist_name ? "by #{artist_name}" : ""}"
    mail(to: submission.email, subject: subject)
  end

  def non_target_supply_artist_rejected(submission:, artist:)
    @submission = submission
    @artist = artist

    @utm_params =
      utm_params(
        source: "sendgrid",
        campaign: "sell",
        term: "cx",
        content: "non-ts-rejected"
      )

    smtpapi category: %w[non_target_supply_artist_rejected],
            unique_args: {
              submission_id: submission.id
            }
    mail(to: submission.email, subject: "An update about your submission")
  end

  def other_submission_rejected(submission:, artist:)
    @submission = submission
    @artist = artist
    @utm_params =
      utm_params(
        source: "sendgrid",
        campaign: "sell",
        term: "cx",
        content: "other-rejected"
      )

    smtpapi category: %w[other_submission_rejected],
            unique_args: {
              submission_id: submission.id
            }
    mail(to: submission.email, subject: "An update about your submission")
  end

  def offer(offer:, artist:)
    @offer = offer
    @submission = offer.submission
    @artist = artist
    @utm_params = offer_utm_params(offer)

    smtpapi category: %w[offer], unique_args: {offer_id: offer.id}
    mail(to: @submission.email, subject: "An Offer for your Artwork")
  end
end
