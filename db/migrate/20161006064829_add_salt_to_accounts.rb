class AddSaltToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :salt, :string
  end
end
