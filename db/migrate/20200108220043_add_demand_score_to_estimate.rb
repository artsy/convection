class AddDemandScoreToEstimate < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :initial_demand_score, :float
    add_column :submissions, :final_demand_score, :float
  end
end
