require 'rails_helper'

describe Submission do
  context 'status' do
    it 'correctly sets the initial status to draft' do
      submission = Submission.create!(artist_id: 'andy-warhol')
      expect(submission.status).to eq 'draft'
    end

    it 'allows only certain statuses' do
      expect(Submission.new(status: 'blah')).not_to be_valid
      expect(Submission.new(status: 'qualified')).to be_valid
      expect(Submission.new(status: 'submitted')).to be_valid
    end
  end

  context 'as_json' do
    let(:submission) { Submission.create!(artist_id: 'andy-warhol', user_id: 'user-id') }
    it 'returns avaiable data' do
      json = submission.as_json
      expect(json['id']).to eq submission.id
      expect(json['artist_id']).to eq 'andy-warhol'
      expect(json['assets']).to eq([])
    end

    it 'returns assets if they exist' do
      submission.assets.create!(gemini_token: 'gemini-token', asset_type: 'image')
      submission.assets.create!(gemini_token: 'gemini-token2', asset_type: 'image')
      json = submission.as_json
      expect(json['id']).to eq submission.id
      expect(json['assets'].map { |a| a['gemini_token'] }).to include('gemini-token', 'gemini-token2')
    end
  end

  context 'formatted_location' do
    it 'correctly formats location fields' do
      submission = Submission.create!(
        location_city: 'Brooklyn',
        location_state: 'New York',
        location_country: 'USA'
      )
      expect(submission.formatted_location).to eq 'Brooklyn, New York, USA'
    end

    it 'returns empty string when location values are nil' do
      submission = Submission.create!
      expect(submission.formatted_location).to be_blank
    end
  end

  context 'formatted_dimensions' do
    it 'correctly formats dimension fields' do
      submission = Submission.create(
        width: '10',
        height: '12',
        depth: '1.75',
        dimensions_metric: 'IN'
      )
      expect(submission.formatted_dimensions).to eq '12 x 10 x 1.75 in'
    end

    it 'returns empty string when dimension values are nil' do
      submission = Submission.create!
      expect(submission.formatted_dimensions).to be_blank
    end
  end
end
