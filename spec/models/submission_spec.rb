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

  context 'category' do
    it 'allows only certain categories' do
      expect(Submission.new(category: nil)).to be_valid
      expect(Submission.new(category: 'blah')).not_to be_valid
      expect(Submission.new(category: 'Painting')).to be_valid
    end
  end

  context 'dimensions_metric' do
    it 'allows only certain categories' do
      expect(Submission.new(dimensions_metric: nil)).to be_valid
      expect(Submission.new(dimensions_metric: 'blah')).not_to be_valid
      expect(Submission.new(dimensions_metric: 'in')).to be_valid
      expect(Submission.new(dimensions_metric: 'cm')).to be_valid
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

  context 'finished_processing_images_for_email?' do
    let(:submission) { Submission.create(category: 'Painting') }

    it 'returns true if there are no assets' do
      expect(submission.finished_processing_images_for_email?).to eq true
    end

    it 'returns true if all of the assets have a medium_rectangle url' do
      submission.assets.create!(
        asset_type: 'image',
        gemini_token: 'gemini1',
        image_urls: { medium_rectangle: 'https://image.jpg' }
      )
      submission.assets.create!(
        asset_type: 'image',
        gemini_token: 'gemini2',
        image_urls: { medium_rectangle: 'https://image2.jpg' }
      )
      expect(submission.finished_processing_images_for_email?).to eq true
    end

    it 'returns false if only some of the images have a medium_rectangle url' do
      submission.assets.create!(
        asset_type: 'image',
        gemini_token: 'gemini1',
        image_urls: { medium_rectangle: 'https://image.jpg' }
      )
      submission.assets.create!(
        asset_type: 'image',
        gemini_token: 'gemini2',
        image_urls: { medium_rectangle: 'https://image2.jpg' }
      )
      submission.assets.create!(
        asset_type: 'image',
        gemini_token: 'gemini3',
        image_urls: { square: 'https://image3.jpg' }
      )
      expect(submission.finished_processing_images_for_email?).to eq false
    end

    it 'returns false if none of the images have a medium_rectangle url' do
      submission.assets.create!(
        asset_type: 'image',
        gemini_token: 'gemini1',
        image_urls: { square: 'https://image.jpg' }
      )
      submission.assets.create!(
        asset_type: 'image',
        gemini_token: 'gemini2',
        image_urls: { square: 'https://image2.jpg' }
      )
      expect(submission.finished_processing_images_for_email?).to eq false
    end
  end
end
