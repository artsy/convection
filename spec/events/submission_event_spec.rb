# frozen_string_literal: true

require "rails_helper"

describe SubmissionEvent do
  let(:submission) do
    Fabricate(
      :submission,
      artist_id: "artistid",
      user: Fabricate(:user, gravity_user_id: "userid"),
      title: "My Artwork",
      state: "submitted",
      medium: "painting",
      year: "1992",
      height: "12",
      width: "14",
      depth: "2",
      dimensions_metric: "in",
      location_city: "New York",
      location_state: "NY",
      location_country: "US",
      category: "Painting",
      signature: true,
      authenticity_certificate: true,
      provenance: "This is the provenance"
    )
  end

  let!(:image1) do
    Fabricate(
      :image,
      submission: submission,
      image_urls: {
        "square" => "http://square1.jpg",
        "large" => "http://foo1.jpg",
        "thumbnail" => "http://thumb1.jpg"
      }
    )
  end

  let!(:image2) do
    Fabricate(
      :image,
      submission: submission,
      image_urls: {
        "square" => "http://square2.jpg",
        "large" => "http://foo2.jpg",
        "thumbnail" => "http://thumb2.jpg"
      }
    )
  end

  let!(:image3) do
    Fabricate(
      :image,
      submission: submission,
      image_urls: {
        "square" => "http://square3.jpg",
        "large" => "http://foo3.jpg",
        "thumbnail" => "http://thumb3.jpg"
      }
    )
  end

  let(:event) { SubmissionEvent.new(model: submission, action: "submitted") }

  before do
    allow(Convection.config).to receive(:auction_offer_form_url).and_return(
      "https://google.com/auction"
    )
    submission.update!(primary_image: image2)
  end

  describe "#object" do
    it "returns proper id and display" do
      expect(event.object[:id]).to eq submission.id
      expect(event.object[:display]).to eq "#{submission.id} (submitted)"
    end
  end

  describe "#subject" do
    it "returns proper id and display" do
      expect(event.subject[:id]).to eq "userid"
      expect(event.subject[:display]).to eq "userid (New York)"
    end
  end

  describe "#properties" do
    it "returns proper properties" do
      expect(event.properties[:title]).to eq "My Artwork"
      expect(event.properties[:artist_id]).to eq "artistid"
      expect(event.properties[:state]).to eq "submitted"
      expect(event.properties[:year]).to eq "1992"
      expect(event.properties[:location_city]).to eq "New York"
      expect(event.properties[:location_state]).to eq "NY"
      expect(event.properties[:location_country]).to eq "US"
      expect(event.properties[:height]).to eq "12"
      expect(event.properties[:width]).to eq "14"
      expect(event.properties[:depth]).to eq "2"
      expect(event.properties[:dimensions_metric]).to eq "in"
      expect(event.properties[:category]).to eq "Painting"
      expect(event.properties[:medium]).to eq "painting"
      expect(event.properties[:provenance]).to eq "This is the provenance"
      expect(event.properties[:signature]).to eq true
      expect(event.properties[:authenticity_certificate]).to eq true
      expect(event.properties[:thumbnail]).to eq "http://thumb2.jpg"
      expect(event.properties[:image_urls]).to match_array %w[
                    http://foo1.jpg
                    http://foo2.jpg
                    http://foo3.jpg
                  ]
      expect(event.properties[:offer_link]).to eq "https://google.com/auction"
    end

    it "returns proper properties for a submission with no processed images and few properties" do
      minimal_submission =
        Fabricate(
          :submission,
          title: "My Artwork",
          artist_id: "artistid",
          year: "1992",
          state: "approved"
        )
      minimal_event =
        SubmissionEvent.new(model: minimal_submission, action: "approved")

      expect(minimal_event.properties[:title]).to eq "My Artwork"
      expect(minimal_event.properties[:artist_id]).to eq "artistid"
      expect(minimal_event.properties[:state]).to eq "approved"
      expect(minimal_event.properties[:year]).to eq "1992"
      expect(minimal_event.properties[:depth]).to eq nil
      expect(minimal_event.properties[:provenance]).to eq nil
      expect(minimal_event.properties[:signature]).to eq false
      expect(minimal_event.properties[:authenticity_certificate]).to eq false
      expect(minimal_event.properties[:thumbnail]).to eq nil
      expect(minimal_event.properties[:image_urls]).to eq []
      expect(
        minimal_event.properties[:offer_link]
      ).to eq "https://google.com/auction"
    end
  end
end
