require 'rails_helper'

describe DemandCalculator do
  let(:artist_id) { 'artistid' }

  let!(:artist_standing_score) do
    Fabricate(:artist_standing_score, artist_id: artist_id, artist_score: 0.50, auction_score: 1.0)
  end

  context 'finding artist scores' do
    it 'uses the score when artist id can be found' do
      scores = DemandCalculator.score(artist_id, 'Painting')
      expect(scores[:artist_score]).to eq artist_standing_score.artist_score
      expect(scores[:auction_score]).to eq artist_standing_score.auction_score
    end

    it 'falls back to a null object when artist score does not exist' do
      scores = DemandCalculator.score('unknown', 'Painting')
      expect(scores[:artist_score]).to eq 0
      expect(scores[:auction_score]).to eq 0
    end
  end

  context 'modifiers' do
    it 'uses the modifier when it can be found' do
      scores = DemandCalculator.score(artist_id, 'Print')
      expected_artist_score = artist_standing_score.artist_score * DemandCalculator::CATEGORY_MODIFIERS['Print']
      expect(scores[:artist_score]).to eq expected_artist_score
    end

    it 'uses the default when category modifier does not exist' do
      scores = DemandCalculator.score(artist_id, 'Photography')
      expected_artist_score = artist_standing_score.artist_score * DemandCalculator::CATEGORY_MODIFIERS['Default']
      expect(scores[:artist_score]).to eq expected_artist_score
    end
  end
end
