class ApplicationController < ActionController::Base
  require 'oauth_session'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

private
  helper_method :current_account

  def current_account
    @current_account ||= begin
      Account.find(session[:account_id]) if session[:account_id]
    end
  end

  def tradegecko_account
    @tradegecko_account ||= @client.Account.current
  end

  def authenticate_user!
    redirect_to "/auth/tradegecko" unless session[:account_id]
  end

  def setup_client
    require 'gecko'
    @client = Gecko::Client.new(ENV["OAUTH_ID"], ENV["OAUTH_SECRET"], {
      site:  OAuthSession.site_path
    })
    @client.access_token = access_token
  end

  def access_token
    @access_token ||= OAuthSession.new(current_account).access_token
  end

  def current_ip
    (request.env['HTTP_X_FORWARDED_FOR'] || request.env['REMOTE_ADDR'] || '').split(',').last
  end
end
