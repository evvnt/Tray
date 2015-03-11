module Tray
  module Models
    class LineItem
      include Virtus.model

      attribute :product_model, Symbol
      attribute :product_id, Integer
      attribute :quantity, Integer, default: 0

      def entity
        @entity ||= Cart::PRODUCT_KEYS.invert[product_model].find(product_id)
      end
    end
  end
end