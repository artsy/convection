module Admin
  class DashboardController < ApplicationController
    include GraphqlHelper

    expose(:submissions) do
      Submission.not_deleted.submitted.order(id: :desc).take(4)
    end

    expose(:offers) { Offer.sent.order(id: :desc).take(4) }

    expose(:consignments) do
      PartnerSubmission.consigned.order(id: :desc).take(4)
    end

    expose(:submissions_count) { Submission.not_deleted.submitted.count }

    expose(:offers_count) { Offer.sent.count }

    expose(:consignments_count) { PartnerSubmission.consigned.count }

    expose(:artist_details) do
      submission_artists = artists_query(submissions.map(&:artist_id)) || {}
      consignment_artists =
        artists_query(consignments.map(&:submission).map(&:artist_id)) || {}
      submission_artists.merge(consignment_artists)
    end

    def index; end
  end
end
