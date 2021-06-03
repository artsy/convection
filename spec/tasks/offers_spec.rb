# frozen_string_literal: true

require "rails_helper"

Rails.application.load_tasks

describe "Offers rake tasks" do
  describe "Offers lapse sent rake task" do
    subject(:invoke_task) do
      Rake.application.invoke_task("offers:lapse_sent[#{date}]")
    end

    let(:date) { "2021-09-01" }
    let(:past_offer) { Fabricate(:offer, state: "sent", sent_at: date.to_date - 1.day) }
    let(:future_offer) { Fabricate(:offer, state: "sent", sent_at: date.to_date + 1.day) }
    let(:future_offer1) { Fabricate(:offer, state: "sent", sent_at: date.to_date + 1.month) }
    let(:future_offer2) { Fabricate(:offer, state: "sent", sent_at: date.to_date + 1.year) }
    let(:past_review_offer) { Fabricate(:offer, state: "review", sent_at: date.to_date - 1.day) }

    it "update the state if offer is set to 'sent' before a certain date" do
      expect { invoke_task }.to(change { past_offer.reload.state }.from("sent").to("lapsed"))
      expect { invoke_task }.not_to(change { future_offer.reload.state })
      expect { invoke_task }.not_to(change { future_offer1.reload.state })
      expect { invoke_task }.not_to(change { future_offer2.reload.state })
      expect { invoke_task }.not_to(change { past_review_offer.reload.state })
    end
  end

  describe "Offers lapse review rake task" do
    subject(:invoke_task) do
      Rake.application.invoke_task("offers:lapse_review[#{date}]")
    end

    let(:date) { "2021-09-01" }
    let(:past_offer) { Fabricate(:offer, state: "review", review_started_at: date.to_date - 1.day) }
    let(:future_offer) { Fabricate(:offer, state: "review", review_started_at: date.to_date + 1.day) }
    let(:future_offer1) { Fabricate(:offer, state: "review", review_started_at: date.to_date + 1.month) }
    let(:future_offer2) { Fabricate(:offer, state: "review", review_started_at: date.to_date + 1.year) }
    let(:past_sent_offer) { Fabricate(:offer, state: "sent", review_started_at: date.to_date - 1.day) }

    it "update the state if offer is set to 'review' before a certain date" do
      expect { invoke_task }.to(change { past_offer.reload.state }.from("review").to("lapsed"))
      expect { invoke_task }.not_to(change { future_offer.reload.state })
      expect { invoke_task }.not_to(change { future_offer1.reload.state })
      expect { invoke_task }.not_to(change { future_offer2.reload.state })
      expect { invoke_task }.not_to(change { past_sent_offer.reload.state })
    end
  end
end
