# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe SubmissionsHelper, type: :helper do
  include ActiveSupport::Testing::TimeHelpers

  context 'formatted_location' do
    it 'correctly formats location fields' do
      submission =
        Fabricate(
          :submission,
          location_city: 'Brooklyn',
          location_state: 'New York',
          location_country: 'USA'
        )
      expect(
        helper.formatted_location(submission)
      ).to eq 'Brooklyn, New York, USA'
    end

    it 'returns empty string when location values are nil' do
      submission =
        Fabricate(
          :submission,
          location_city: '', location_state: '', location_country: ''
        )
      expect(helper.formatted_location(submission)).to be_blank
    end

    it 'works if the location has no city' do
      submission =
        Fabricate(
          :submission,
          location_city: '', location_state: 'Tokyo', location_country: 'Japan'
        )
      expect(helper.formatted_location(submission)).to eq('Tokyo, Japan')
    end
  end

  context 'formatted_dimensions' do
    it 'correctly formats dimension fields' do
      submission =
        Fabricate(
          :submission,
          width: '10', height: '12', depth: '1.75', dimensions_metric: 'in'
        )
      expect(helper.formatted_dimensions(submission)).to eq '12x10x1.75in'
    end

    it 'returns empty string when dimension values are nil' do
      submission = Fabricate(:submission, width: nil, height: nil, depth: nil)
      expect(helper.formatted_dimensions(submission)).to be_blank
    end
  end

  context 'formatted_dimensions_inch_cm' do
    let(:submission_with_inch) do
      Fabricate(
        :submission,
        width: '10', height: '12', depth: '1.75', dimensions_metric: 'in'
      )
      end
    let(:submission_with_cm) do
      Fabricate(
        :submission,
        width: '30', height: '40', depth: '2.54', dimensions_metric: 'cm'
      )
    end

    it 'returns empty string when dimension values are nil' do
      submission = Fabricate(:submission, width: nil, height: nil, depth: nil)
      expect(helper.formatted_dimensions_inch_cm(submission)).to be_blank
    end

    it 'returns array of formatted dimensions for both metrics' do
      expect(helper.formatted_dimensions_inch_cm(submission_with_inch)).to match_array [
        '12 x 10 x 1.75 in',
        '30.48 x 25.4 x 4.45 cm'
      ]
      expect(helper.formatted_dimensions_inch_cm(submission_with_cm)).to match_array [
        '15.75 x 11.81 x 1.0 in',
        '40 x 30 x 2.54 cm'
      ]
    end
  end

  context 'formatted_editions' do
    it 'it correctly formats the editions fields' do
      submission =
        Fabricate(:submission, edition_size: 200, edition_number: '10a')
      expect(helper.formatted_editions(submission)).to eq '10a/200'
    end

    it 'returns nil if there is no edition_number' do
      submission =
        Fabricate(:submission, edition_size: 200, edition_number: nil)
      expect(helper.formatted_editions(submission)).to eq nil
    end
  end

  context 'formatted_category' do
    it 'correctly formats category and medium fields if both are present' do
      submission =
        Fabricate(:submission, category: 'Painting', medium: 'Oil on linen')
      expect(
        helper.formatted_category(submission)
      ).to eq 'Painting, Oil on linen'
    end

    it 'correctly formats category and medium fields if category is nil' do
      submission = Fabricate(:submission, category: nil, medium: 'Oil on linen')
      expect(helper.formatted_category(submission)).to eq 'Oil on linen'
    end

    it 'correctly formats category and medium fields if medium is nil' do
      submission = Fabricate(:submission, category: 'Painting', medium: nil)
      expect(helper.formatted_category(submission)).to eq 'Painting'
    end

    it 'correctly formats category and medium fields if category is empty' do
      submission = Fabricate(:submission, category: nil, medium: 'Oil on linen')
      expect(helper.formatted_category(submission)).to eq 'Oil on linen'
    end

    it 'correctly formats category and medium fields if medium is empty' do
      submission = Fabricate(:submission, category: 'Painting', medium: '')
      expect(helper.formatted_category(submission)).to eq 'Painting'
    end
  end

  context 'formatted_medium_metadata' do
    let(:submission) do
      Fabricate(
        :submission,
        medium: 'Oil on linen',
        edition_number: '10a',
        edition_size: 100,
        height: 10,
        width: 10,
        depth: 15,
        dimensions_metric: 'cm'
      )
    end
    it 'displays the correct text when all info is present' do
      expect(
        helper.formatted_medium_metadata(submission)
      ).to eq 'Oil on linen, 10x10x15cm, Edition 10a/100'
    end
    it 'truncates the medium correctly' do
      submission.update!(
        medium:
          'Since the late 1990s, KAWS has produced art toys to be circulated as global commodities. ' \
            'By engaging directly with branding, production, and distribution, his toys compel their ' \
            'collectors to consider what the commodity status of art objects is today. Seen here, the ' \
            "\"Accomplice” characters from KAWS are appropriately branded with the artist's trademark \"X\" " \
            "to replace each of the figure's original eyes. The black example is from an edition of 500 " \
            'and the pink example is from an edition of 1000'
      )
      expect(helper.formatted_medium_metadata(submission)).to eq(
        'Since the late 1990s, KAWS has produced art toys to be circulated as global commodities. By engag..., 10x10x15cm, Edition 10a/100'
      )
    end
    it 'displays the correct text when there is no medium' do
      submission.update!(medium: nil)
      expect(
        helper.formatted_medium_metadata(submission)
      ).to eq '10x10x15cm, Edition 10a/100'
    end
    it 'displays the correct text when there is no edition number/size' do
      submission.update!(edition_number: nil, edition_size: nil)
      expect(
        helper.formatted_medium_metadata(submission)
      ).to eq 'Oil on linen, 10x10x15cm'
    end
    it 'displays the correct text when there are no dimensions' do
      submission.update!(height: nil, width: nil, depth: nil)
      expect(
        helper.formatted_medium_metadata(submission)
      ).to eq 'Oil on linen, Edition 10a/100'
    end
    it 'displays the correct text when there is only a medium' do
      submission.update!(
        height: nil,
        width: nil,
        depth: nil,
        edition_number: nil,
        edition_size: nil
      )
      expect(helper.formatted_medium_metadata(submission)).to eq 'Oil on linen'
    end
    it 'displays the correct text when there is only an edition number/size' do
      submission.update!(height: nil, width: nil, depth: nil, medium: nil)
      expect(
        helper.formatted_medium_metadata(submission)
      ).to eq 'Edition 10a/100'
    end
    it 'displays the correct text when there are only dimensions' do
      submission.update!(medium: nil, edition_number: nil, edition_size: nil)
      expect(helper.formatted_medium_metadata(submission)).to eq '10x10x15cm'
    end
    it 'displays the correct text when there is no info' do
      submission.update!(
        medium: nil,
        edition_number: nil,
        edition_size: nil,
        height: nil,
        width: nil,
        depth: nil
      )
      expect(helper.formatted_medium_metadata(submission)).to eq ''
    end
  end

  context 'reviewer_byline' do
    it 'shows the correct label for an approved submission' do
      stub_gravity_root
      stub_gravity_user
      submission =
        Fabricate(:submission, state: 'approved', approved_by: 'userid')
      expect(helper.reviewer_byline(submission)).to eq 'Approved by Jon Jonson'
    end
    it 'shows the correct label for a rejected submissions' do
      stub_gravity_root
      stub_gravity_user
      submission =
        Fabricate(:submission, state: 'rejected', rejected_by: 'userid')
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

  context 'artist_supply_priority' do
    context 'when is_p1' do
      subject { helper.artist_supply_priority(is_p1: true, target_supply: true) }
      it { is_expected.to eq 'P1' }
    end

    context 'when target_supply/p2' do
      subject { helper.artist_supply_priority(is_p1: false, target_supply: true) }
      it { is_expected.to eq 'P2' }
    end

    context 'none' do
      subject { helper.artist_supply_priority(is_p1: false, target_supply: false) }
      it { is_expected.to eq nil }
    end
  end
end
