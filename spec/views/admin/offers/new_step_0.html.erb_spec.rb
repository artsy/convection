# frozen_string_literal: true

require "rails_helper"

describe "admin/offers/new_step_0.html.erb", type: :feature do
  let(:submission) { Fabricate(:submission) }
  let(:partner) { Fabricate(:partner, name: "First Partner") }
  let(:partner2) { Fabricate(:partner, name: "Second Partner") }

  context "with a submission" do
    before do
      allow_any_instance_of(Admin::OffersController).to receive(
        :require_artsy_authentication
      )
      page.visit new_step_0_admin_offers_path(submission_id: submission.id)
    end

    it "displays the page title and content" do
      expect(page).to have_content("New Offer")
      expect(page).to have_content("Submission ##{submission.id}")
    end

    it "displays an error message if no partner is selected" do
      expect(find("input#offer_type_auction_consignment")).to be_checked
      click_button("Next")
      expect(page).to have_content(
        "Offer requires type, submission, and partner."
      )
    end

    it "keeps the offer type selected when an error is shown" do
      choose("offer_type_purchase")
      click_button("Next")
      expect(page).to have_content(
        "Offer requires type, submission, and partner."
      )
      expect(find("input#offer_type_purchase")).to be_checked
    end
  end

  context "without a submission", js: true do
    before do
      allow_any_instance_of(Admin::OffersController).to receive(
        :require_artsy_authentication
      )
      page.visit new_step_0_admin_offers_path
    end

    it "displays the page title and content" do
      expect(page).to have_content("New Offer")
    end

    it "displays an error message if a submission and partner are not selected" do
      expect(find("input#offer_type_auction_consignment")).to be_checked
      click_button("Next")
      expect(page).to have_content(
        "Offer requires type, submission, and partner."
      )
    end

    it "allows you to select a submission and partner" do
      evaluate_script("$('#submission_id').val(#{submission.id})")
      evaluate_script("$('#partner_id').val(#{partner.id})")
      click_button("Next")
      expect(page).to have_content(
        "Auction consignment offer for Submission ##{
          submission.id
        } by First Partner"
      )
    end

    it "keeps the partner selected if you revisit the page on error" do
      evaluate_script("$('#partner_id').val(#{partner.id})")
      click_button("Next")
      expect(page).to have_content("Partner First Partner")
      expect(page).to have_content(
        "Offer requires type, submission, and partner."
      )
    end

    it "keeps the submission selected if you revisit the page on error" do
      evaluate_script("$('#submission_id').val(#{submission.id})")
      click_button("Next")
      expect(page).to have_content("Submission ##{submission.id}")
      expect(page).to have_content(
        "Offer requires type, submission, and partner."
      )
    end
  end
end
