# frozen_string_literal: true

require 'rails_helper'

describe UtmParamsHelper, type: :helper do
  describe "utm_params" do
    it "returns the right utm params" do
      expect(utm_params(source: "source", campaign: "campaign")).to eq(
        {utm_source: "source", utm_medium: "email", utm_campaign: "campaign"}
      )
    end
    it "correctly transforms additional args" do
      expect(utm_params(source: "source", campaign: "campaign", one: "one", two: 'two')).to eq(
        {utm_source: "source", utm_medium: "email", utm_campaign: "campaign", utm_one: "one", utm_two: 'two'}
      )
    end
  end

  describe "offer_utm_params" do
    context "Offer::NET_PRICE" do
      offer = Fabricate(:offer, offer_type: "net price")
      it "correctly returns utm params for Offer::NET_PRICE" do 
        expect(offer_utm_params(offer)).to eq(
          {
            utm_campaign: "sell", 
            utm_content:"net-price-offer", 
            utm_medium: "email", 
            utm_source:"sendgrid", 
            utm_term:"cx"
          }
        )
      end
    end
    context "Offer::RETAIL" do
      offer = Fabricate(:offer, offer_type: "retail")
      it "correctly returns utm params for Offer::RETAIL" do 
        expect(offer_utm_params(offer)).to eq(
          {
            utm_campaign: "sell", 
            utm_content:"retail-offer", 
            utm_medium: "email", 
            utm_source:"sendgrid", 
            utm_term:"cx"
          }
        )
      end
    end
    context "Offer::PURCHASE" do
      offer = Fabricate(:offer, offer_type: "purchase")
      it "correctly returns utm params for Offer::PURCHASE" do 
        expect(offer_utm_params(offer)).to eq(
          {
            utm_campaign: "sell", 
            utm_content:"purchase-offer", 
            utm_medium: "email", 
            utm_source:"sendgrid", 
            utm_term:"cx"
          }
        )
      end
    end
  end
end
