class Account < ApplicationRecord
  def self.find_or_create_from_omniauth(auth)
    params = auth[:extra][:raw_info]
    account = self.find_or_initialize_by(tradegecko_id: params[:account_id])
    account.save!
    account
  end

  def update_from_access_token(access_token)
    self.access_token  = access_token.token
    self.refresh_token = access_token.refresh_token
    self.expires_at    = access_token.expires_at
    account_hash       = access_token.get('/accounts/current').parsed['account'].symbolize_keys
    self.save
  end
end
