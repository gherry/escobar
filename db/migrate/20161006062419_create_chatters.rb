class CreateChatters < ActiveRecord::Migration[5.0]
  def change
    create_table :chatters do |t|
      t.integer :account_id
      t.string  :motion_ai_id
      t.string  :email
      t.integer :tradegecko_company_id
      t.integer :tradegecko_contact_id
      t.jsonb   :options

      t.timestamps
    end
  end
end
