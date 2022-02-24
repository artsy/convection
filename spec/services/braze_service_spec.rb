# frozen_string_literal: true

require 'rails_helper'

describe BrazeService do
  describe '#send_swa_my_collection_email' do
    context 'when submission is not ready' do
      let(:submission) { Fabricate(:submission) }

      before do
        allow_any_instance_of(Submission).to receive(:ready?).and_return(false)
      end

      it 'raises a Still processing images error' do
        expect {
          BrazeService.send_swa_my_collection_email(submission.id)
        }.to raise_error('Still processing images.')
      end
    end

    context 'when submission has no email' do
      let(:submission) { Fabricate(:submission, user: nil, user_email: nil) }

      it 'raises a User lacks email error' do
        expect {
          BrazeService.send_swa_my_collection_email(submission.id)
        }.to raise_error('User lacks email.')
      end
    end

    context 'when submission is valid' do
      let(:gravity_user_id) { 'userid' }
      let(:email_subject) { '[TESTING] SWA Braze integration' }
      let(:braze_campaign_id) { Convection.config.braze_campaign_id }
      let(:submission) do
        Fabricate(
          :submission,
          user: Fabricate(:user, gravity_user_id: gravity_user_id)
        )
      end

      let(:expected_recipient) do
        [
          {
            external_user_id: gravity_user_id,
            trigger_properties: {
              email_subject: email_subject
            }
          }
        ]
      end

      before do
        allow(BrazeApi).to receive(:trigger_campaign_send).and_return(true)
      end

      it 'calls BrazeApi#trigger_campaign_send with the expected values' do
        expect(BrazeApi).to receive(:trigger_campaign_send).with(
          braze_campaign_id,
          expected_recipient
        )

        BrazeService.send_swa_my_collection_email(submission.id)
      end
    end
  end
end
