class AddExternalIdToSubmissions < ActiveRecord::Migration[6.1]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto') # need to enable pgcrypto to use `gen_random_uuid()` function

    add_column :submissions,
               :uuid,
               :uuid,
               default: 'gen_random_uuid()',
               null: false
    add_index :submissions, :uuid, unique: true
  end
end
