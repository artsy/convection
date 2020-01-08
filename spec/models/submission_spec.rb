require 'rails_helper'
require 'support/gravity_helper'

describe Submission do
  let(:submission) { Fabricate(:submission) }

  context 'state' do
    it 'correctly sets the initial state to draft' do
      expect(submission.state).to eq 'draft'
    end

    it 'allows only certain states' do
      expect(Submission.new(state: 'blah')).not_to be_valid
      expect(Submission.new(state: 'approved')).to be_valid
      expect(Submission.new(state: 'submitted')).to be_valid
    end
  end

  context 'scopes' do
    describe 'completed' do
      it 'returns the number of non-draft submissions' do
        Fabricate(:submission, state: 'approved')
        Fabricate(:submission, state: 'rejected')
        Fabricate(:submission, state: 'draft')
        Fabricate(:submission, state: 'submitted')
        expect(Submission.completed.count).to eq(3)
      end

      it 'returns 0 if there are only draft submissions' do
        Fabricate(:submission)
        expect(Submission.completed.count).to eq(0)
      end
    end
  end

  context 'demand_score' do
    before do
      Fabricate(:artist_appraisal_rating, artist_id: 'artistid', score: 0.69)
      @submission = Fabricate(:submission, artist_id: 'artistid', medium: nil)
    end

    describe 'demand_score' do
      it 'is the final demand score or the initial demand score' do
        expect(@submission.demand_score).to eq 0.69
        @submission.update_attributes(final_demand_score: 0.420)
        expect(@submission.demand_score).to eq 0.42

      end
    end
    describe 'initial_demand_score' do
      it 'is calculated on every save prior to submission' do
        expect(@submission.initial_demand_score).to eq 0.69
        expect{@submission.update(category: 'Print')}.to change{ @submission.initial_demand_score}
      end
      it 'no longer updates on submission'
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

  context 'artist' do
    it 'returns nil if it cannot find the object' do
      stub_gravity_root
      stub_request(:get, "#{Convection.config.gravity_api_url}/artists/#{submission.artist_id}")
        .to_raise(Faraday::ResourceNotFound)
      expect(submission.artist).to be_nil
      expect(submission.artist_name).to be_nil
    end
    it 'returns the object if it can find it' do
      stub_gravity_root
      stub_gravity_artist(id: submission.artist_id, name: 'Andy Warhol')
      expect(submission.artist_name).to eq 'Andy Warhol'
    end
  end

  context 'thumbnail' do
    it 'returns nil if there is no thumbnail image' do
      Fabricate(:unprocessed_image, submission: submission)
      expect(submission.thumbnail).to eq nil
    end
    it 'returns nil if there are no assets' do
      expect(submission.thumbnail).to eq nil
    end
    it 'returns the first image with a thumbnail url' do
      Fabricate(:image, submission: submission, image_urls: { 'thumbnail' => 'https://thumb.jpg' })
      expect(submission.thumbnail).to eq 'https://thumb.jpg'
    end
  end

  context 'real deletion (destroy)' do
    it 'deletes associated partner submissions and offers' do
      Fabricate(:partner_submission, submission: submission)
      Fabricate(:offer, submission: submission)
      expect do
        submission.destroy
      end
        .to change { PartnerSubmission.count }.by(-1)
                                              .and change { Offer.count }.by(-1)
    end
  end
end
