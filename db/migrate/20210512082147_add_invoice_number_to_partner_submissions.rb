# frozen_string_literal: true

class AddInvoiceNumberToPartnerSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :partner_submissions, :invoice_number, :string
  end
end
