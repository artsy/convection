# frozen_string_literal: true

class AddConditionReportToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :condition_report, :string
  end
end
