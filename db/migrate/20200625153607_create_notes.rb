class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :notes do |t|
      t.string :created_by
      t.text :body
      t.references :submission, foreign_key: true

      t.timestamps
    end
  end
end
