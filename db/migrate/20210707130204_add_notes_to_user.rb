class AddNotesToUser < ActiveRecord::Migration[6.1]
  def change
    add_reference :notes, :user, foreign_key: true
  end
end
