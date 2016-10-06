class Chatter < ApplicationRecord
  belongs_to :account

  store_accessor :options, :unconfirmed_email
end
