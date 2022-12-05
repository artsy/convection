class CreateConsignmentInquiries < ActiveRecord::Migration[6.1]
  def change
    create_table :consignment_inquiries do |t|
      t.string :email, index: true
      t.string :gravity_user_id, index: true
      t.text :message
      t.string :name
      t.string :phone_number
      t.timestamps
    end
  end
end
