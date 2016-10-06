class ProductsCardSerializer
  def initialize(products, variants)
    @products = products
    @variants = variants
  end

  def to_json
    {
      cards: @products.map { |product| product_card_hash(product) }
    }
  end

  def product_card_hash(product)
    chosen_variants = find_variants(product)

    {
      cardTitle:    product.name,
      cardSubtitle: product.description,
      cardImage:    "http://efdreams.com/data_images/dreams/vodka/vodka-07.jpg",
      cardLink:     "https://go.tradegecko.com",
      buttons:      chosen_variants.map { |v| variant_button(product, v) }
    }
  end

  def variant_button(product, variant)
    {
      buttonText: "Buy #{variant.name} ($#{variant.retail_price})",
      buttonType: "module",
      target:     137660
    }
  end

  def find_variants(product)
    @variants.select { |variant| variant.product_id.try(:to_i) == product.id.try(:to_i) }
  end
end
