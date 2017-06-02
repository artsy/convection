class AddRemindersSentCount < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :reminders_sent_count, :integer, default: 0
  end
end
