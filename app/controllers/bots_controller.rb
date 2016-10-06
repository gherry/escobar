class BotsController < ActionController::Base
  require 'oauth_session'
  require 'orders_card_serializer'
  require 'products_card_serializer'

  def email
    current_chatter.unconfirmed_email = params[:reply]
    current_chatter.save

    render json: {email: current_chatter.unconfirmed_email}
  end

  def email_confirm
    if current_chatter.unconfirmed_email.present?
      current_chatter.email = current_chatter.unconfirmed_email
      tradegecko_company    = current_client.Company.where(email: current_chatter.email).first
      current_chatter.tradegecko_company_id = tradegecko_company.try(:id) || create_default_company(current_chatter.email).try(:id)
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

  def product_search
    products = current_client.Product.where(q: params[:reply])

    if products.present?
      product_ids = products.map(&:id)
      variants = current_client.Variant.where(product_id: product_ids)
      render json: ProductsCardSerializer.new(products, variants).to_json
    else
      render json: {}
    end
  end

  def create_order
    variant_id = params[:reply].split("|").last.to_i

    if variant_id.present?
      address    = current_client.Address.where(company_id: current_chatter.tradegecko_company_id).first
      address  ||= create_default_address

      order_params = {
        billing_address_id:  address.id,
        shipping_address_id: address.id,
        company_id:          current_chatter.tradegecko_company_id,
        email:               current_chatter.email,
        issued_at:           Time.now,
        payment_status:      "unpaid",
        reference_number:    "Order placed via Facebook Messenger bot",
        status:              "active",
        tax_treatment:       "exclusive",
        default_price_list_id: "retail",
        order_line_items_attributes: [{
          variant_id: variant_id,
          quantity: 1
        }]
      }

      new_order_id = JSON.parse(current_client.access_token.post("/orders", body: {"order" => order_params}).body)["order"]["id"]
      order = current_client.Order.find(new_order_id)

      render json: OrdersCardSerializer.new([order]).to_json
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

  def create_default_company(email)
    company_name = email.split("@").first.split(".").map(&:capitalize).join(" ")
    to_create_company = current_client.Company.build(company_type: 'consumer', name: company_name, email: email)
    to_create_company.save
    to_create_company
  end

  def create_default_address
    to_create_address = current_client.Address.build(
      label: "Shipping Address",
      address1: "Shipping Street 123",
      company_id: current_chatter.tradegecko_company_id
    )
    to_create_address.save
    to_create_address
  end
end
