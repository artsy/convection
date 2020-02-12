# frozen_string_literal: true

class UpdatePrimaryImage < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :submissions, column: :primary_image_id
    add_foreign_key :submissions,
                    :assets,
                    column: :primary_image_id, on_delete: :nullify
  end
end
