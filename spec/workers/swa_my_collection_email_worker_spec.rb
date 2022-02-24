# frozen_string_literal: true

require 'rails_helper'

describe SwaMyCollectionEmailWorker, type: :workers do
  describe 'perform' do
    let(:submission_id) { '0' }

    before do
      allow(BrazeService).to receive(:send_swa_my_collection_email).and_return(
        true
      )
    end

    it 'calls BrazeService#send_swa_my_collection_email with the given submission_id' do
      expect(BrazeService).to receive(:send_swa_my_collection_email).with(
        submission_id
      )

      SwaMyCollectionEmailWorker.new.perform(submission_id)
    end
  end
end
