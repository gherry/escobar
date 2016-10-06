class BotsController < ActionController::Base
  require 'oauth_session'
  require 'orders_card_serializer'

  def email
    puts current_chatter.id
    puts "Adding unconfirmed: #{current_chatter.unconfirmed_email}"

    current_chatter.unconfirmed_email = params[:reply]
    current_chatter.save

    render json: {email: current_chatter.unconfirmed_email}
  end

  def email_confirm
    if current_chatter.unconfirmed_email.present? && params[:reply].try(:downcase) == "yes"
      puts current_chatter.id
      puts "Confirming: #{current_chatter.unconfirmed_email}"
      current_chatter.email = current_chatter.unconfirmed_email
      current_chatter.save
    end

    render json: {email: current_chatter.email}
  end

  def order_search
    puts "Calling order search! #{params[:reply]}"
    orders = current_client.Order.where(q: params[:reply])

    if orders.present?
      render json: OrdersCardSerializer.new(orders).to_json
    else
      render json: {}
    end
  end

  def fulfillment_search
    fulfillment = current_client.Fulfillment.where(q: params[:reply]).first

    if fulfillment
      render json: fulfillment.to_h
    else
      render json: {}
    end
  end

  def tracking_url_search
    fulfillment = current_client.Fulfillment.where(tracking_url: params[:reply]).first

    if fulfillment
      render json: fulfillment.to_h
    else
      render json: {}
    end
  end

  def orders
    render json: {a: 1, b: params[:bot_id], c: params[:from], tradegecko_id: current_account.tradegecko_id}
  end

private

  def current_account
    @current_account ||= Account.find_by(salt: params[:bot_id])
  end

  def current_chatter
    @current_chatter ||= current_account.chatters.find_or_create_by(motion_ai_id: params[:from])
  end

  def current_client
    @current_client ||= begin
      require 'gecko'
      client = Gecko::Client.new(ENV["OAUTH_ID"], ENV["OAUTH_SECRET"], {
        site:  OAuthSession.site_path
      })
      client.access_token = access_token
      client
    end
  end

  def access_token
    @access_token ||= begin
      OAuthSession.new(current_account).access_token
    end
  end
end
