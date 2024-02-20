# frozen_string_literal: true

module Admin
  class PartnersController < ApplicationController
    include GraphqlHelper

    expose(:partners) do
      matching_partners = Partner.all
      if params[:term].present?
        matching_partners = matching_partners.search_by_name(params[:term])
      end
      matching_partners.page(page).per(size)
    end

    expose(:term) { params[:term] }

    def index
      respond_to do |format|
        format.html
        format.json { render json: partners || [] }
      end
    end

    def create
      if params[:gravity_partner_id]
        partner =
          Partner.new(
            gravity_partner_id: params[:gravity_partner_id],
            name: params[:name]
          )
      end
      if partner&.save
        flash[:notice] = "Partner successfully created."
        redirect_to admin_partners_path
      else
        flash.now[:error] =
          "Error creating gravity partner. #{
            partner&.errors&.full_messages&.to_sentence
          }"
        render "index"
      end
    end

    def match_partner
      if params[:term]
        @term = params[:term]
        @partners = match_partners_query(@term)
      end
      respond_to { |format| format.json { render json: @partners || [] } }
    end
  end
end
