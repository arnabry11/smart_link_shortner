class AddTokenVersionToUsers < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :users, :token_version, :integer, default: 1, null: false
    add_index :users, :token_version, algorithm: :concurrently
  end
end
