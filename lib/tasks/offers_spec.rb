# frozen_string_literal: true

require "rails_helper"

Rails.application.load_tasks

describe "Offers lapse sent rake task" do
  subject(:invoke_task) do
    Rake.application.invoke_task("offers:lapse_sent[#{date}]")
  end

  let(:date) { "2021-09-01" }
  let(:past_offer) { Fabricate(:offer, state: "sent", sent_at: date.to_date - 1.day) }
  let(:future_offer) { Fabricate(:offer, state: "sent", sent_at: date.to_date + 1.day) }
  # ... add other offers that shouldn't change

  it "testing..." do
    expect { invoke_task }.to(change { past_offer.reload.state }.from("sent").to("lapsed"))
    expect { invoke_task }.not_to(change { future_offer.reload.state })
  end
end