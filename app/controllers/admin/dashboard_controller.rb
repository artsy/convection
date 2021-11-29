# frozen_string_literal: true

module Admin
  class DashboardController < ApplicationController
    include GraphqlHelper

    expose(:grouped_submissions) do
      DashboardReportingQuery::Submission.grouped_by_state
    end

    expose(:unreviewed_submissions) do
      DashboardReportingQuery::Submission.unreviewed_user_submissions(
        @current_user
      )
    end

    expose(:grouped_offers) { DashboardReportingQuery::Offer.grouped_by_state }

    expose(:grouped_consignments) do
      DashboardReportingQuery::Consignment.grouped_by_state_and_partner
    end

    def index; end
  end
end
