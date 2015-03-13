module Tray
  module ORM
    def add(item, quantity = 1, options = {})
      product_model = Cart::PRODUCT_KEYS[item.class]
      line_items.push(product_model: product_model, product_id: item.id, quantity: quantity, options: options)
    end

    def remove(product_model, product_id, options = {})
      line_items.decrement(product_model, product_id)
    end

    def empty
      line_items.clear
      promo_codes.clear
    end
  end
end