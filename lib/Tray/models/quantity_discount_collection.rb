module Tray
  module Models
    class QuantityDiscountCollection < Array
      def push(event_id, discount_amount)
        discount = QuantityDiscount.new(event_id: event_id, discount_amount: discount_amount)
        super(discount)
      end

      def <<(event_id, discount_amount)
        push(event_id, discount_amount)
      end
    end
  end
end
