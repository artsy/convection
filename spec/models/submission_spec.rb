require 'rails_helper'

describe Submission do
  context 'state' do
    it 'correctly sets the initial state to draft' do
      submission = Submission.create!(artist_id: 'andy-warhol')
      expect(submission.state).to eq 'draft'
    end

    it 'allows only certain states' do
      expect(Submission.new(state: 'blah')).not_to be_valid
      expect(Submission.new(state: 'qualified')).to be_valid
      expect(Submission.new(state: 'submitted')).to be_valid
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
