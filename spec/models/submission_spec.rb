require 'rails_helper'

describe Submission do
  let(:submission) { Fabricate(:submission) }

  context 'state' do
    it 'correctly sets the initial state to draft' do
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

  context 'processed_images' do
    it 'returns an empty array if there are no images' do
      expect(submission.processed_images).to eq []
    end

    it 'returns an empty array if there are no processed images' do
      Fabricate(:unprocessed_image, submission: submission)
      expect(submission.processed_images).to eq []
    end

    it 'returns only the processed images' do
      asset1 = Fabricate(:image, submission: submission)
      Fabricate(:unprocessed_image, submission: submission)
      expect(submission.processed_images).to eq [asset1]
    end
  end

  context 'finished_processing_images_for_email?' do
    it 'returns true if there are no assets' do
      expect(submission.finished_processing_images_for_email?).to eq true
    end

    it 'returns true if all of the assets have a square url' do
      2.times { Fabricate(:image, submission: submission) }
      expect(submission.finished_processing_images_for_email?).to eq true
    end

    it 'returns false if only some of the images have a square url' do
      Fabricate(:image, submission: submission)
      Fabricate(:unprocessed_image, submission: submission)
      expect(submission.finished_processing_images_for_email?).to eq false
    end

    it 'returns false if none of the images have a square url' do
      2.times { Fabricate(:unprocessed_image, submission: submission) }
      expect(submission.finished_processing_images_for_email?).to eq false
    end
  end
end
