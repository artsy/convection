class AddDemandScoreToEstimate < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :demand_score, :float
  end
end
