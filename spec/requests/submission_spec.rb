require 'rails_helper'
require 'support/gravity_helper'

describe 'Submission Flow', type: :request do
  let(:jwt_token) { JWT.encode({ aud: 'gravity', sub: 'userid' }, Convection.config.jwt_secret) }
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  before do
    allow(Convection.config).to receive(:access_token).and_return('auth-token')
  end

  describe 'Creating a submission without a photo initially' do
    before do
      # first create the submission
      post '/api/submissions', params: {
        artist_id: 'artistid',
        user_id: 'userid',
        title: 'My Artwork',
        medium: 'painting',
        year: '1992',
        height: '12',
        width: '14',
        dimensions_metric: 'in',
        location_city: 'New York',
        category: 'Painting'
      }, headers: headers

      expect(response.status).to eq 201
      @submission = Submission.find(JSON.parse(response.body)['id'])

      expect(@submission.assets.count).to eq 0

      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail(email: 'michael@bluth.com')
      stub_gravity_artist

      put "/api/submissions/#{@submission.id}", params: {
        state: 'submitted'
      }, headers: headers
      expect(response.status).to eq 201
      expect(@submission.reload.state).to eq 'submitted'
    end

    it 'sends an initial reminder email to users' do
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 2
      expect(emails.first.html_part.body).to include("We're missing photos of your work")
    end

    it 'sends a follow-up reminder after 1 day' do
      Timecop.travel(1.day.from_now)
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 3
      expect(emails.last.html_part.body).to include('Complete your consignment submission')
      expect(emails.last.to_email).to eq('user@example.com')
    end

    it 'sends a thank you email if they upload a photo after the second reminder' do
      Timecop.travel(1.day.from_now)
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 3
      expect(emails.last.html_part.body).to include('Complete your consignment submission')
      expect(emails.last.to_email).to eq('user@example.com')

      post '/api/assets', params: {
        submission_id: @submission.id,
        gemini_token: 'gemini-token'
      }, headers: headers

      expect(@submission.assets.count).to eq 1
      expect(@submission.assets.map(&:image_urls).uniq).to eq([{}])

      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 4
      expect(emails.last.html_part.body).to include('Thank you for submitting')
      expect(emails.last.to_email).to eq('user@example.com')

      expect do
        Timecop.travel(1.day.from_now)
      end.to_not change(ActionMailer::Base.deliveries.count)

      # it doesn't send an additional email if they upload another photo
      expect do
        post '/api/assets', params: {
          submission_id: @submission.id,
          gemini_token: 'gemini-token'
        }, headers: headers
      end.to_not change(ActionMailer::Base.deliveries.count)
      expect(@submission.assets.count).to eq 2
    end

    describe 'If the user uploads a photo before the second reminder' do
      it 'sends them a thank you email but no follow-up reminder' do
        post '/api/assets', params: {
          submission_id: @submission.id,
          gemini_token: 'gemini-token'
        }, headers: headers

        expect(@submission.assets.count).to eq 1
        expect(@submission.assets.map(&:image_urls).uniq).to eq([{}])

        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 3
        expect(emails.last.html_part.body).to include('Thank you for submitting')
        expect(emails.last.to_email).to eq('user@example.com')

        expect do
          Timecop.travel(1.day.from_now)
        end.to_not change(ActionMailer::Base.deliveries.count)
      end
    end
  end

  describe 'Creating a submission (as a client might) with a photo' do
    it 'creates and updates a submission/assets' do
      # first create the submission
      post '/api/submissions', params: {
        artist_id: 'artistid',
        user_id: 'userid',
        title: 'My Artwork',
        medium: 'painting',
        year: '1992',
        height: '12',
        width: '14',
        dimensions_metric: 'in',
        location_city: 'New York',
        category: 'Painting'
      }, headers: headers

      expect(response.status).to eq 201
      submission = Submission.find(JSON.parse(response.body)['id'])

      # upload assets to that submission
      post '/api/assets', params: {
        submission_id: submission.id,
        gemini_token: 'gemini-token'
      }, headers: headers

      post '/api/assets', params: {
        submission_id: submission.id,
        gemini_token: 'gemini-token2'
      }, headers: headers

      expect(submission.assets.count).to eq 2
      expect(submission.assets.map(&:image_urls).uniq).to eq([{}])

      # accept gemini callbacks for image urls
      post '/api/callbacks/gemini', params: {
        access_token: 'auth-token',
        token: 'gemini-token',
        image_url: { medium: 'https://new-image.jpg' },
        metadata: { id: submission.id }
      }

      post '/api/callbacks/gemini', params: {
        access_token: 'auth-token',
        token: 'gemini-token2',
        image_url: { medium: 'https://another-image.jpg' },
        metadata: { id: submission.id }
      }
      expect(submission.assets.detect { |a| a.gemini_token == 'gemini-token' }.reload.image_urls)
        .to eq('medium' => 'https://new-image.jpg')
      expect(submission.assets.detect { |a| a.gemini_token == 'gemini-token2' }.reload.image_urls)
        .to eq('medium' => 'https://another-image.jpg')

      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail(email: 'michael@bluth.com')
      stub_gravity_artist

      # update the submission status and notify
      put "/api/submissions/#{submission.id}", params: {
        state: 'submitted'
      }, headers: headers
      expect(response.status).to eq 201
      expect(submission.reload.state).to eq 'submitted'
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 2
      expect(emails.first.html_part.body).to include('https://new-image.jpg')

      # GET to retrieve the image url for the submission
      get '/api/assets', params: { submission_id: submission.id }, headers: headers
      expect(response.status).to eq 200
      expect(JSON.parse(response.body).map { |a| a['gemini_token'] })
        .to include('gemini-token', 'gemini-token2')
    end
  end
end
