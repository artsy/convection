require 'rails_helper'

describe NotificationService do
  let(:submission) do
    Fabricate(:submission,
      artist_id: 'artistid',
      user_id: 'userid',
      title: 'My Artwork',
      medium: 'painting',
      year: '1992',
      height: '12',
      width: '14',
      dimensions_metric: 'in',
      location_city: 'New York',
      category: 'Painting')
  end

  describe '#post_submission_event' do
    it 'calls Artsy::EventService.post_event with an instance of BaseEvent' do
      expect(Artsy::EventService).to receive(:post_event).once.with(
        topic: 'consignments',
        event: instance_of(SubmissionEvent)
      )
      NotificationService.post_submission_event(submission.id, 'submitted')
    end
  end
end
