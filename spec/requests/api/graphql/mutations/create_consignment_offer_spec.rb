# frozen_string_literal: true

require "rails_helper"
require "support/gravity_helper"

describe "createConsignmentOffer mutation" do
  let!(:partner) { Fabricate :partner }
  let!(:submission) { Fabricate :submission, state: "approved" }

  let(:token) do
    payload = {aud: "gravity", sub: "userid", roles: "admin"}
    JWT.encode(payload, Convection.config.jwt_secret)
  end

  let(:headers) { {"Authorization" => "Bearer #{token}"} }

  let(:mutation_inputs) { <<-INPUTS }
    {
      gravityPartnerId: "#{partner.gravity_partner_id}",
      submissionId: #{submission.id},
      commissionPercentWhole: 10
    }
  INPUTS

  let(:mutation) { <<-GRAPHQL }
    mutation {
      createConsignmentOffer(input: #{mutation_inputs}){
        consignmentOffer {
          id
        }
      }
    }
  GRAPHQL

  describe "invalid requests" do
    context "with an unauthorized request" do
      let(:token) { "foo.bar.baz" }

      it "returns an error for that request" do
        post "/api/graphql", params: {query: mutation}, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        create_response = body["data"]["createConsignmentOffer"]
        expect(create_response).to eq nil

        error_message = body["errors"][0]["message"]
        expect(error_message).to eq "Can't access createConsignmentOffer"
      end
    end

    context "with a request missing an app token" do
      let(:token) do
        payload = {sub: "userid", roles: "user"}
        JWT.encode(payload, Convection.config.jwt_secret)
      end

      it "returns an error for that request" do
        post "/api/graphql", params: {query: mutation}, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        create_response = body["data"]["createConsignmentOffer"]
        expect(create_response).to eq nil

        error_message = body["errors"][0]["message"]
        expect(error_message).to eq "Can't access createConsignmentOffer"
      end
    end

    context "with a request from an untrusted client app" do
      let(:token) do
        payload = {aud: "bad-actor", sub: "userid", roles: "untrusted"}
        JWT.encode(payload, Convection.config.jwt_secret)
      end

      it "returns an error for that request" do
        post "/api/graphql", params: {query: mutation}, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        create_response = body["data"]["createConsignmentOffer"]
        expect(create_response).to eq nil

        error_message = body["errors"][0]["message"]
        expect(error_message).to eq "Can't access createConsignmentOffer"
      end
    end

    context "with a request from a trusted client app" do
      let(:token) do
        payload = {aud: "good-actor", sub: nil, roles: "trusted"}
        JWT.encode(payload, Convection.config.jwt_secret)
      end

      it "creates an offer" do
        post "/api/graphql", params: {query: mutation}, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)
        create_response = body["data"]["createConsignmentOffer"]

        offer = Offer.last

        offer_response = create_response["consignmentOffer"]
        expect(offer_response).to include({"id" => offer.id.to_s})
      end
    end

    context "with a request missing a gravity partner id" do
      let(:mutation_inputs) { <<-INPUTS }
        {
          submissionId: #{submission.id},
          commissionPercentWhole: 10
        }
      INPUTS

      it "returns an error for that request" do
        post "/api/graphql", params: {query: mutation}, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        error_message = body["errors"][0]["message"]
        expect(error_message).to match "is required"
      end
    end

    context "with a request missing a submission id" do
      let(:mutation_inputs) { <<-INPUTS }
        {
          gravityPartnerId: "#{partner.gravity_partner_id}",
          commissionPercentWhole: 10
        }
      INPUTS

      it "returns an error for that request" do
        post "/api/graphql", params: {query: mutation}, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        error_message = body["errors"][0]["message"]
        expect(error_message).to match "is required"
      end
    end

    context "with a request missing a commission percent" do
      let(:mutation_inputs) { <<-INPUTS }
        {
          gravityPartnerId: "#{partner.gravity_partner_id}",
          submissionId: #{submission.id}
        }
      INPUTS

      it "returns an error for that request" do
        post "/api/graphql", params: {query: mutation}, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        error_message = body["errors"][0]["message"]
        expect(error_message).to match "is required"
      end
    end
  end

  describe "valid requests" do
    context "with just the minimum" do
      it "creates an offer" do
        add_default_stubs

        expect {
          post "/api/graphql", params: {query: mutation}, headers: headers
        }.to change(Offer, :count).by(1)

        expect(response.status).to eq 200
        body = JSON.parse(response.body)
        create_response = body["data"]["createConsignmentOffer"]

        offer = Offer.last

        offer_response = create_response["consignmentOffer"]
        expect(offer_response).to include({"id" => offer.id.to_s})
      end
    end

    context "with an auction offer" do
      let(:mutation_inputs) { <<-INPUTS }
        {
          commissionPercentWhole: 10,
          createdById: "foo",
          currency: "#{Currency::SUPPORTED.first}",
          deadlineToConsign: "ASAP",
          gravityPartnerId: "#{partner.gravity_partner_id}",
          highEstimateDollars: 1000,
          insuranceInfo: "1.50%",
          lowEstimateDollars: 500,
          notes: "We would be honored to offer this work in our May sale in Los Angeles.",
          offerType: "#{Offer::AUCTION_CONSIGNMENT}",
          otherFeesInfo: "50 USD",
          partnerInfo: "user@example.com",
          photographyInfo: "100 USD",
          saleDate: "2018-01-01",
          saleName: "Our best sale",
          shippingInfo: "Shipping to be absorbed by consignor.",
          state: "draft",
          submissionId: #{submission.id}
        }
      INPUTS

      it "creates an offer" do
        add_default_stubs

        expect {
          post "/api/graphql", params: {query: mutation}, headers: headers
        }.to change(Offer, :count).by(1)

        expect(response.status).to eq 200
        body = JSON.parse(response.body)
        create_response = body["data"]["createConsignmentOffer"]

        offer = Offer.last

        offer_response = create_response["consignmentOffer"]
        expect(offer_response).to include({"id" => offer.id.to_s})
      end
    end
  end
end
