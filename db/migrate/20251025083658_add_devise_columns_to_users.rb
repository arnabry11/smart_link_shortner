class AddDeviseColumnsToUsers < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    # Add Devise required columns
    add_column :users, :encrypted_password, :string, null: false, default: ""
    add_column :users, :remember_created_at, :datetime
    add_column :users, :reset_password_sent_at, :datetime
    add_column :users, :reset_password_token, :string
    add_index :users, :reset_password_token, unique: true, algorithm: :concurrently

    # Remove password_digest since we're using Devise
    safety_assured { remove_column :users, :password_digest }
  end
end
