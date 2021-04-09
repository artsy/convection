# frozen_string_literal: true

class PartnerMailer < ApplicationMailer
  helper :url, :submissions, :offers, :application

  def submission_digest(
    users_to_submissions:,
    partner_name:,
    partner_type:,
    email:,
    **args
  )
    @users_to_submissions = users_to_submissions
    @submissions_artists = args[:submissions_artists]
    @partner_type = partner_type
    @utm_params =
      utm_params(
        source: 'consignment-partner-digest', campaign: 'consignment-complete'
      )
    smtpapi category: %w[submission_digest],
            unique_args: { partner_name: partner_name }

    current_date = Time.now.utc.strftime('%B %-d')
    mail(
      to: email,
      from: Convection.config.admin_email_address,
      subject:
        "New Artsy Consignments #{current_date}: #{args[:submissions_count]} works"
    ) { |format| format.html { render layout: 'mailer_no_footer' } }
  end

  def offer_introduction(offer:, artist:, email:)
    @offer = offer
    @submission = offer.submission
    @artist = artist
    @utm_params =
      utm_params(
        source: 'consignment-offer-introduction', campaign: 'consignment-offer'
      )

    smtpapi category: %w[offer], unique_args: { offer_id: offer.id }
    mail(
      to: email, subject: 'The consignor has expressed interest in your offer'
    )
  end

  def offer_rejection(offer:, artist:, email:)
    @offer = offer
    @submission = offer.submission
    @artist = artist
    @utm_params =
      utm_params(
        source: 'consignment-offer-rejected', campaign: 'consignment-offer'
      )

    smtpapi category: %w[offer], unique_args: { offer_id: offer.id }
    mail(to: email, subject: 'A response to your consignment offer')
  end
end
