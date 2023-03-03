class AddRecipientEmailToConsignmentInquiry < ActiveRecord::Migration[6.1]
  def change
    add_column :consignment_inquiries, :recipient_email, :string
    add_index :consignment_inquiries, [:recipient_email], unique: false
  end
end
