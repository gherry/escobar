class OAuthSession
  attr_reader :account

  def initialize(account)
    @account = account
  end

  def access_token
    @access_token ||= fetch_access_token
  end

private
  def fetch_access_token
    token = OAuth2::AccessToken.new(self.class.oauth_client, account.access_token, {
      refresh_token: account.refresh_token,
      expires_at:    account.expires_at,

    })

    AccessTokenWrapper::Base.new(token) do |new_token, ex|
      account.update_from_access_token(new_token)
    end
  end

  def self.oauth_client
    @oauth_client ||= OAuth2::Client.new(ENV["OAUTH_ID"], ENV["OAUTH_SECRET"], {
      site: site_path,
      connection_opts: {
        headers: Gecko::Client.default_headers.merge({
          "HTTP_GECKO_BYPASS" => "1"
        })
      }
    })
  end

  def self.site_path
    ENV["TRADEGECKO_API_URL"] || "https://api.tradegecko.com"
  end
end
