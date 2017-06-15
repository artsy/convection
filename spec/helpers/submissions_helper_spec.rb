require 'rails_helper'

describe SubmissionsHelper, type: :helper do
  context 'formatted_location' do
    it 'correctly formats location fields' do
      submission = Submission.create!(
        location_city: 'Brooklyn',
        location_state: 'New York',
        location_country: 'USA'
      )
      expect(helper.formatted_location(submission)).to eq 'Brooklyn, New York, USA'
    end

    it 'returns empty string when location values are nil' do
      submission = Submission.create!
      expect(helper.formatted_location(submission)).to be_blank
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
      expect(helper.formatted_dimensions(submission)).to eq '12 x 10 x 1.75 in'
    end

    it 'returns empty string when dimension values are nil' do
      submission = Submission.create!
      expect(helper.formatted_dimensions(submission)).to be_blank
    end
  end

  context 'formatted_category' do
    it 'correctly formats category and medium fields if both are present' do
      submission = Submission.create(
        category: 'Painting',
        medium: 'Oil on linen'
      )
      expect(helper.formatted_category(submission)).to eq 'Painting, Oil on linen'
    end

    it 'correctly formats category and medium fields if category is nil' do
      submission = Submission.create(
        category: nil,
        medium: 'Oil on linen'
      )
      expect(helper.formatted_category(submission)).to eq 'Oil on linen'
    end

    it 'correctly formats category and medium fields if medium is nil' do
      submission = Submission.create(
        category: 'Painting',
        medium: nil
      )
      expect(helper.formatted_category(submission)).to eq 'Painting'
    end

    it 'correctly formats category and medium fields if category is empty' do
      submission = Submission.create(
        category: '',
        medium: 'Oil on linen'
      )
      expect(helper.formatted_category(submission)).to eq 'Oil on linen'
    end

    it 'correctly formats category and medium fields if medium is empty' do
      submission = Submission.create(
        category: 'Painting',
        medium: ''
      )
      expect(helper.formatted_category(submission)).to eq 'Painting'
    end
  end
end
