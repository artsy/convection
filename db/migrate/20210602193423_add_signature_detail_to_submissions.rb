# frozen_string_literal: true

class AddSignatureDetailToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :signature_detail, :string
  end
end
