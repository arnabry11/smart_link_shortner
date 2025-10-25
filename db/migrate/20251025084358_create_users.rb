class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest
      t.string :first_name
      t.string :last_name
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
