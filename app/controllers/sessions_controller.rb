require 'oauth_session'
class SessionsController < ApplicationController
  def create
    account = Account.find_or_create_from_omniauth(auth)
    token = OAuth2::AccessToken.new(OAuthSession.oauth_client,
      auth[:credentials][:token],
      auth[:credentials].slice(:refresh_token, :expires_at)
    )
    account.update_from_access_token(token)
    session[:account_id] = account.id
    redirect_to root_url
  end

  def destroy
    session.delete(:account_id)
    render text: "You have been logged out"
  end

private
  def auth
    request.env["omniauth.auth"]
  end
end
