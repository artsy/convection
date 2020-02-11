class NullArtistStandingScore
  def artist_score
    0
  end

  def auction_score
    0
  end
end

class DemandCalculator
  CATEGORY_MODIFIERS = {
    'Default' => 0.5, 'Painting' => 1, 'Print' => 0.75
  }.freeze

  def self.score(artist_id, category)
    new(artist_id, category).score
  end

  def initialize(artist_id, category)
    @artist_id = artist_id
    @category = category
    @artist_standing_score =
      ArtistStandingScore.where(artist_id: artist_id).order(created_at: :asc)
        .limit(1)
        .first ||
        NullArtistStandingScore.new
  end

  def score
    { artist_score: artist_score, auction_score: auction_score }
  end

  private

  def artist_score
    calculate_demand_score(@artist_standing_score.artist_score)
  end

  def auction_score
    calculate_demand_score(@artist_standing_score.auction_score)
  end

  def calculate_demand_score(base_score)
    return 0 unless base_score.positive?

    modifier =
      CATEGORY_MODIFIERS.fetch(@category, CATEGORY_MODIFIERS['Default'])
    base_score * modifier
  end
end
