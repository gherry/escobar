class BotsController < ActionController::Base
  require 'oauth_session'
  require 'orders_card_serializer'

  def email
    current_chatter.unconfirmed_email = params[:reply]
    current_chatter.save

    render json: {email: current_chatter.unconfirmed_email}
  end

  def email_confirm
    if current_chatter.unconfirmed_email.present? && params[:reply].try(:downcase) == "yes"
      tradegecko_company = current_client.Company.where(email: current_chatter.unconfirmed_email).first
      current_chatter.tradegecko_company_id = tradegecko_company.try(:id)
      current_chatter.email = current_chatter.unconfirmed_email
      current_chatter.save
    end

    render json: {email: current_chatter.email}
  end

  def orders
    if current_chatter.email.present?
      orders = current_client.Order.where(company_id: current_chatter.tradegecko_company_id)
      fulfillments = current_client.Fulfillment.where(order_ids: orders.map(&:id))
      render json: OrdersCardSerializer.new(orders, fulfillments).to_json
    else
      render json: {}
    end
  end

  def order_search
    orders = current_client.Order.where(q: params[:reply])

    if orders.present?
      fulfillments = current_client.Fulfillment.where(order_ids: orders.map(&:id))
      render json: OrdersCardSerializer.new(orders, fulfillments).to_json
    else
      render json: {}
    end
  end

  def fulfillment_search
    fulfillments = current_client.Fulfillment.where(q: params[:reply])

    if fulfillments.present?
      order_ids = fulfillments.map(&:order_id)
      orders = current_client.Order.where(ids: order_ids)
      render json: OrdersCardSerializer.new(orders, fulfillments).to_json
    else
      render json: {}
    end
  end

  def tracking_url_search
    fulfillments = current_client.Fulfillment.where(tracking_url: params[:reply])

    if fulfillments.present?
      order_ids = fulfillments.map(&:order_id)
      orders = current_client.Order.where(ids: order_ids)
      render json: OrdersCardSerializer.new(orders, fulfillments).to_json
    else
      render json: {}
    end
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
