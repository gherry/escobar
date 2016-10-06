class OrdersCardSerializer
  def initialize(orders, fulfillments=[])
    @orders       = orders
    @fulfillments = fulfillments || []
  end

  def to_json
    {
      cards: @orders.map { |order| order_card_hash(order) }
    }
  end

  def order_card_hash(order)
    {
      cardTitle:    card_title(order),
      cardSubtitle: card_subtitle(order),
      cardImage:    "https://d3h6ue1fvxa32i.cloudfront.net/assets/avatar-order-big-6e9e5789f149e38b6a7c94421e6b89187e4e9f5ed3ccf39877e9858d4320934e.png",
      cardLink:     order.document_url,
      buttons:      [view_order_button(order), pay_button(order), tracking_url_button(order)].compact
    }
  end

  def card_title(order)
    [order.order_number, "$#{order.total}"].join(" - ")
  end

  def card_subtitle(order)
    if order.fulfillment_status.to_sym == :shipped
      "Shipped at: #{order.ship_at}"
    else
      "Not shipped yet"
    end
  end

  def random_image
    [
      "https://www.patrontequila.com/binaries/content/gallery/patrontequila/products/patron-silver/bottle.png",
      "http://efdreams.com/data_images/dreams/vodka/vodka-07.jpg",
      "http://www.exclusivebottle.ch/shop/images/product_images/popup_images/Kavalan-Concertmaster-Port-Cask-50ml_400.jpg",
      "http://hiredgunscreative.com/wp-content/uploads/2015/02/baba-yaga-1-2-3.jpg"
    ].sample
  end

  def view_order_button(order)
    {
      buttonText: "View Order",
      buttonType: "url",
      target:     order.document_url
    }
  end

  def pay_button(order)
    if order.payment_status.to_sym == :paid
      {
        buttonText: "Pay",
        buttonType: "url",
        target:     order.document_url
      }
    end
  end

  def tracking_url_button(order)
    fulfillment = find_fulfillment(order)
    if fulfillment && fulfillment.tracking_url.present?
      {
        buttonText: "Tracking URL",
        buttonType: "url",
        target:     fulfillment.tracking_url
      }
    end
  end

  def find_fulfillment(order)
    @fulfillments.detect { |fulfillment| fulfillment.order_id.try(:to_i) == order.id.try(:to_i) }
  end
end
