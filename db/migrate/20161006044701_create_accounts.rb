class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts do |t|
      t.integer :tradegecko_id
      t.string :access_token
      t.string :refresh_token
      t.string :expires_at
      t.jsonb :options

      t.timestamps
    end
  end
end
