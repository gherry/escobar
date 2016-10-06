class OrdersCardSerializer
  def initialize(orders)
    @orders = orders
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
      cardImage:    random_image,
      cardLink:     order.document_url,
      buttons:      [view_order_button(order), pay_button(order)].compact
    }
  end

  def card_title(order)
    [order.order_number, "$#{order.total}"].join(" - ")
  end

  def card_subtitle(order)
    if order.fulfillment_status.to_sym == :shipped
      "Shipped at: #{order.shipped_at}"
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
end
