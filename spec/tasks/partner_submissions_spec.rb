# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

describe 'Consigments cancel open rake task' do
  subject(:invoke_task) do
    Rake.application.invoke_task("partner_submissions:cancel_open[#{date}]")
  end

  let(:date) { '2021-09-01' }
  let(:past_consignment) do
    Fabricate(:consignment, state: 'open', created_at: date.to_date - 1.day)
  end
  let(:future_consignment) do
    Fabricate(:consignment, state: 'open', created_at: date.to_date + 1.day)
  end
  let(:future_consignment1) do
    Fabricate(:consignment, state: 'open', created_at: date.to_date + 1.month)
  end
  let(:future_consignment2) do
    Fabricate(:consignment, state: 'open', created_at: date.to_date + 1.year)
  end
  let(:past_sold_consignment) do
    Fabricate(:consignment, state: 'sold', created_at: date.to_date - 1.day)
  end

  it "update the state if consigment is set to 'open' before a certain date" do
    expect { invoke_task }.to(
      change { past_consignment.reload.state }.from('open').to('canceled')
    )
    expect { invoke_task }.not_to(change { future_consignment.reload.state })
    expect { invoke_task }.not_to(change { future_consignment1.reload.state })
    expect { invoke_task }.not_to(change { future_consignment2.reload.state })
    expect { invoke_task }.not_to(change { past_sold_consignment.reload.state })
  end
end
