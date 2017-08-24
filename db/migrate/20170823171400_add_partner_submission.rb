class AddPartnerSubmission < ActiveRecord::Migration[5.0]
  def change
    create_table :partner_submissions do |t|
      t.timestamps
    end
    add_reference :partner_submissions, :submission, foreign_key: true, index: true
    add_reference :partner_submissions, :partner, foreign_key: true, index: true
  end
end
