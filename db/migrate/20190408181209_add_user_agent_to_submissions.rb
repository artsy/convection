class AddUserAgentToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :user_agent, :string
  end
end
