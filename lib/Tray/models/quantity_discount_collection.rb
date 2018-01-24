module Tray
  module Models
    class QuantityDiscountCollection < Array
      def push(quantity_discount)
        self.delete_if{ |e| e.event_id == quantity_discount[:event_id] }
        discount = QuantityDiscount.new(quantity_discount)
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
