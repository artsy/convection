class AddAdminReceiptSentAt < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :admin_receipt_sent_at, :datetime
  end
end
