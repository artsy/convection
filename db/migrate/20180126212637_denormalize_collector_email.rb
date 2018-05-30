class DenormalizeCollectorEmail < ActiveRecord::Migration[5.1]
  def change
    add_column :submissions, :user_email, :string
    execute "create extension pg_trgm;"
  end
end
