module Admin
  class PartnersController < ApplicationController
    include GraphqlHelper

    before_action :set_pagination_params, only: [:index]

    def index
      @size = (params[:size] || 100).to_i
      @partners = Partner.order(id: :asc).page(@page).per(@size)
      partners_hash = @partners.map { |p| [p.gravity_partner_id, p.id] }.to_h
      aggregated_partner_details = partners_query(partners_hash.keys).map do |gravity_partner_id, details|
        [gravity_partner_id, { given_name: details[:given_name], partner_id: partners_hash[gravity_partner_id] }]
      end
      @partner_details = aggregated_partner_details.sort_by { |_gravity_id, details| details[:given_name].downcase }
    end
  end
end
