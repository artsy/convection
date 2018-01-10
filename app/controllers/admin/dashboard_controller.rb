module Admin
  class DashboardController < ApplicationController
    include GraphqlHelper

    expose(:submissions) do
      Submission.submitted.order(id: :desc).take(4)
    end

    expose(:offers) do
      Offer.sent.order(id: :desc).take(4)
    end

    expose(:consignments) do
      PartnerSubmission.consigned.order(id: :desc).take(4)
    end

    expose(:submissions_count) do
      Submission.submitted.count
    end

    expose(:offers_count) do
      Offer.sent.count
    end

    expose(:consignments_count) do
      PartnerSubmission.consigned.count
    end

    def index
      @artist_details = artists_query(submissions.map(&:artist_id))
    end
  end
end
