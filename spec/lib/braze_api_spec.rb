# frozen_string_literal: true

require 'rails_helper'

describe BrazeApi do
  describe '.handle_response' do
    let(:response) do
      double(:mock_response, body: response_body, status: response_status)
    end

    context 'with a 5xx response' do
      let(:response_status) { 500 }
      let(:response_body) { '' }

      it 'raises TryAgainError' do
        expect { BrazeApi.handle_response(response) }.to raise_error(
          BrazeApi::TryAgainError
        )
      end
    end

    context 'with invalid json' do
      let(:response_status) { 200 }
      let(:response_body) { 'invalid json' }
      let(:error_body) { { 'errors' => 'unable to parse response as json' } }

      it 'rescues, sends error to Raven and returns an error hash' do
        message = 'Braze API Errors: unable to parse response as json'
        expect(Raven).to receive(:capture_message).with(message)
        body = BrazeApi.handle_response(response)
        expect(body).to eq(error_body)
      end
    end

    context 'with valid json that includes an error' do
      let(:response_status) { 200 }
      let(:response_body) { { 'errors' => 'invalid API call' }.to_json }

      it 'sends error to Raven and returns an error hash' do
        message = 'Braze API Errors: invalid API call'
        expect(Raven).to receive(:capture_message).with(message)
        body = BrazeApi.handle_response(response)
        expect(body.to_json).to eq response_body
      end
    end

    context 'with valid json and no errors' do
      let(:response_status) { 200 }
      let(:response_body) { { 'message' => 'success' }.to_json }

      it 'returns the parsed body' do
        expect(Raven).to_not receive(:capture_message)
        body = BrazeApi.handle_response(response)
        expect(body.to_json).to eq response_body
      end
    end
  end
end
