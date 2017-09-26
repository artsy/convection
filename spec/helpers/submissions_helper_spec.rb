require 'rails_helper'
require 'support/gravity_helper'

describe SubmissionsHelper, type: :helper do
  context 'formatted_location' do
    it 'correctly formats location fields' do
      submission = Fabricate(:submission,
        location_city: 'Brooklyn',
        location_state: 'New York',
        location_country: 'USA')
      expect(helper.formatted_location(submission)).to eq 'Brooklyn, New York, USA'
    end

    it 'returns empty string when location values are nil' do
      submission = Fabricate(:submission,
        location_city: '',
        location_state: '',
        location_country: '')
      expect(helper.formatted_location(submission)).to be_blank
    end

    it 'works if the location has no city' do
      submission = Fabricate(:submission,
        location_city: '',
        location_state: 'Tokyo',
        location_country: 'Japan')
      expect(helper.formatted_location(submission)).to eq('Tokyo, Japan')
    end
  end

  context 'formatted_dimensions' do
    it 'correctly formats dimension fields' do
      submission = Fabricate(:submission,
        width: '10',
        height: '12',
        depth: '1.75',
        dimensions_metric: 'in')
      expect(helper.formatted_dimensions(submission)).to eq '12x10x1.75in'
    end

    it 'returns empty string when dimension values are nil' do
      submission = Fabricate(:submission, width: nil, height: nil, depth: nil)
      expect(helper.formatted_dimensions(submission)).to be_blank
    end
  end

  context 'formatted_editions' do
    it 'it correctly formats the editions fields' do
      submission = Fabricate(:submission,
        edition_size: 200,
        edition_number: '10a')
      expect(helper.formatted_editions(submission)).to eq '10a/200'
    end

    it 'returns nil if there is no edition_number' do
      submission = Fabricate(:submission,
        edition_size: 200,
        edition_number: nil)
      expect(helper.formatted_editions(submission)).to eq nil
    end
  end

  context 'formatted_category' do
    it 'correctly formats category and medium fields if both are present' do
      submission = Fabricate(:submission,
        category: 'Painting',
        medium: 'Oil on linen')
      expect(helper.formatted_category(submission)).to eq 'Painting, Oil on linen'
    end

    it 'correctly formats category and medium fields if category is nil' do
      submission = Fabricate(:submission,
        category: nil,
        medium: 'Oil on linen')
      expect(helper.formatted_category(submission)).to eq 'Oil on linen'
    end

    it 'correctly formats category and medium fields if medium is nil' do
      submission = Fabricate(:submission,
        category: 'Painting',
        medium: nil)
      expect(helper.formatted_category(submission)).to eq 'Painting'
    end

    it 'correctly formats category and medium fields if category is empty' do
      submission = Fabricate(:submission,
        category: nil,
        medium: 'Oil on linen')
      expect(helper.formatted_category(submission)).to eq 'Oil on linen'
    end

    it 'correctly formats category and medium fields if medium is empty' do
      submission = Fabricate(:submission,
        category: 'Painting',
        medium: '')
      expect(helper.formatted_category(submission)).to eq 'Painting'
    end
  end

  context 'reviewer_byline' do
    it 'shows the correct label for an approved submission' do
      stub_gravity_root
      stub_gravity_user
      submission = Fabricate(:submission, state: 'approved', approved_by: 'userid')
      expect(helper.reviewer_byline(submission)).to eq 'Approved by Jon Jonson'
    end
    it 'shows the correct label for a rejected submissions' do
      stub_gravity_root
      stub_gravity_user
      submission = Fabricate(:submission, state: 'rejected', rejected_by: 'userid')
      expect(helper.reviewer_byline(submission)).to eq 'Rejected by Jon Jonson'
    end
    it 'shows the correct label for an approved submission with no user' do
      submission = Fabricate(:submission, state: 'approved')
      expect(helper.reviewer_byline(submission)).to eq 'Approved by '
    end
    it 'shows the correct label for a rejected submission with no user' do
      submission = Fabricate(:submission, state: 'rejected')
      expect(helper.reviewer_byline(submission)).to eq 'Rejected by '
    end
  end
end
