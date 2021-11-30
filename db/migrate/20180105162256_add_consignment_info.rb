# frozen_string_literal: true

class AddConsignmentInfo < ActiveRecord::Migration[5.0]
  def change
    add_reference :submissions,
                  :consigned_partner_submission,
                  references: :partner_submissions,
                  index: true
    add_foreign_key :submissions,
                    :partner_submissions,
                    column: :consigned_partner_submission_id

    add_reference :partner_submissions,
                  :accepted_offer,
                  references: :offers,
                  index: true
    add_foreign_key :partner_submissions, :offers, column: :accepted_offer_id

    add_column :partner_submissions, :partner_commission_percent, :float
    add_column :partner_submissions, :artsy_commission_percent, :float
    add_column :partner_submissions, :sale_name, :string
    add_column :partner_submissions, :sale_location, :string
    add_column :partner_submissions, :sale_lot_number, :string
    add_column :partner_submissions, :sale_date, :datetime
    add_column :partner_submissions, :sale_price_cents, :integer
    add_column :partner_submissions, :sale_currency, :string
    add_column :partner_submissions, :partner_invoiced_at, :datetime
    add_column :partner_submissions, :partner_paid_at, :datetime
    add_column :partner_submissions, :notes, :text
    add_column :partner_submissions, :state, :string
    add_column :partner_submissions, :reference_id, :string
  end
end
