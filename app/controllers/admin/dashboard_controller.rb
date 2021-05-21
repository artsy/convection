# frozen_string_literal: true

module Admin
  class DashboardController < ApplicationController
    include GraphqlHelper

    expose(:grouped_submissions) { DashboardReportingQuery::Submission.grouped_by_state }

    expose(:unreviewed_submissions) do
      DashboardReportingQuery::Submission.unreviewed_user_submissions(@current_user)
    end

    expose(:grouped_offers) { DashboardReportingQuery::Offer.grouped_by_state }

    expose(:grouped_consignments) { DashboardReportingQuery::Consignment.grouped_by_state_and_partner }

    def index; end
  end
end
