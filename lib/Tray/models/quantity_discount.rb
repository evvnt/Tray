module Tray
  module Models
    class QuantityDiscount
      include Virtus.model

      attribute :event_id, Integer
      attribute :discount_amount, Integer
      attribute :quantity_discounts, Array, default: []
      attribute :ticket_discount_list, Array[Hash], default: []

    end
  end
end
