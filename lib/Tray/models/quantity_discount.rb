module Tray
  module Models
    class QuantityDiscount
      include Virtus.model

      attribute :event_id, Integer
      attribute :discount_amount, Integer
      attribute :quantity_discounts, Array, default: []

    end
  end
end
