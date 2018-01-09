module Tray
  module Models
    class QuantityDiscountCollection < Array
      def push(event_id, discount_amount)
        discount = QuantityDiscount.new(event_id: event_id, discount_amount: discount_amount)
        super(discount)
      end

      def <<(quantity_discount)
        if quantity_discount.kind_of?(Hash)
           super(QuantityDiscount.new(quantity_discount))
        else
           super
        end
      end
    end
  end
end
