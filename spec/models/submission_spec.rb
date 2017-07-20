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

  context 'user' do
    it 'returns nil if it cannot find the object' do
      stub_gravity_root
      stub_request(:get, "#{Convection.config.gravity_api_url}/users/#{submission.user_id}")
        .to_raise(Faraday::ResourceNotFound)
      expect(submission.user).to be_nil
      expect(submission.user_name).to be_nil
    end
    it 'returns the object if it can find it' do
      stub_gravity_root
      stub_gravity_user(id: submission.user_id, name: 'Buster Bluth')
      expect(submission.user_name).to eq 'Buster Bluth'
    end
  end

  context 'user detail' do
    it 'returns nil if it cannot find the object' do
      stub_gravity_root
      stub_gravity_user(id: submission.user_id, name: 'Buster Bluth')
      stub_request(:get, "#{Convection.config.gravity_api_url}/user_details/#{submission.user_id}")
        .to_raise(Faraday::ResourceNotFound)
      expect(submission.user_name).to eq 'Buster Bluth'
    end
    it 'returns the object if it can find it' do
      stub_gravity_root
      stub_gravity_user(id: submission.user_id, name: 'Buster Bluth')
      stub_gravity_user_detail(id: submission.user_id, email: 'buster@bluth.com')
      expect(submission.user_name).to eq 'Buster Bluth'
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
end
