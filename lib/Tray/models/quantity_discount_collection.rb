module Tray
  module Models
    class QuantityDiscountCollection < Array
      def push(event_id, discount_amount)
        discount = QuantityDiscount.new(event_id: event_id, discount_amount: discount_amount)
        super(discount)
      end

      def <<(discount)
        push(discount)
      end
    end
  end
end
