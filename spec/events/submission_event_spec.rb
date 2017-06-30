require 'rails_helper'

describe SubmissionEvent do
  let(:submission) do
    Fabricate(:submission,
      artist_id: 'artistid',
      user_id: 'userid',
      title: 'My Artwork',
      state: 'submitted',
      medium: 'painting',
      year: '1992',
      height: '12',
      width: '14',
      depth: '2',
      dimensions_metric: 'in',
      location_city: 'New York',
      location_state: 'NY',
      location_country: 'US',
      category: 'Painting')
  end
  let(:event) { SubmissionEvent.new(model: submission, action: 'submitted') }
  describe '#object' do
    it 'returns proper id and display' do
      expect(event.object[:id]).to eq submission.id
      expect(event.object[:display]).to eq "#{submission.id} (submitted)"
    end
  end
  describe '#subject' do
    it 'returns proper id and display' do
      expect(event.subject[:id]).to eq 'userid'
      expect(event.subject[:display]).to eq 'userid (New York)'
    end
  end
  describe '#properties' do
    it 'returns proper properties' do
      expect(event.properties[:title]).to eq 'My Artwork'
      expect(event.properties[:artist_id]).to eq 'artistid'
      expect(event.properties[:state]).to eq 'submitted'
      expect(event.properties[:year]).to eq '1992'
      expect(event.properties[:location_city]).to eq 'New York'
      expect(event.properties[:location_state]).to eq 'NY'
      expect(event.properties[:location_country]).to eq 'US'
      expect(event.properties[:height]).to eq '12'
      expect(event.properties[:width]).to eq '14'
      expect(event.properties[:depth]).to eq '2'
      expect(event.properties[:dimensions_metric]).to eq 'in'
      expect(event.properties[:category]).to eq 'Painting'
      expect(event.properties[:medium]).to eq 'painting'
    end
  end
end
