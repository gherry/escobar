class ProductsCardSerializer
  def initialize(products, variants, images)
    @products = products
    @variants = variants
    @images   = images
  end

  def to_json
    {
      cards: @products.map { |product| product_card_hash(product) }
    }
  end

  def product_card_hash(product)
    chosen_variants = find_variants(product)
    chosen_images   = find_images(chosen_variants.first)

    chosen_image = begin
      if chosen_images.present?
        image_url(chosen_images.first)
      else
        "https://d3h6ue1fvxa32i.cloudfront.net/assets/product-placeholder-63841eaad72d038d071ced3a69b9c542e1636cedc83ecc25b66caca512ffdd9a.png"
      end
    end

    {
      cardTitle:    product.name,
      cardSubtitle: product.description,
      cardImage:    chosen_image,
      cardLink:     "https://go.tradegecko.com",
      buttons:      chosen_variants.map { |v| variant_button(product, v) } + [browse_more_button]
    }
  end

  def variant_button(product, variant)
    {
      buttonText: "Buy #{variant.name} ($#{variant.retail_price})",
      buttonType: "module",
      target:     "Order #{product.name} #{variant.name} | #{variant.id}"
    }
  end

  def browse_more_button
    {
      buttonText: "Browse more",
      buttonType: "module",
      target:     "Browse more"
    }
  end

  def find_variants(product)
    @variants.select { |variant| variant.product_id.try(:to_i) == product.id.try(:to_i) }
  end

  def find_images(variant)
    @images.select { |image| image.variant_id.try(:to_i) == variant.id.try(:to_i) }
  end

  def image_url(image)
    image.base_path + "/" + image.file_name
  end
end
