module Tray
  module Models
    class PromoCode
      include Virtus.model

      attribute :discount_code_id, Integer

      def discount_code
        @discount_code ||= Cart::PRODUCT_KEYS.invert[:discount].find(discount_code_id)
      end

      def apply_to_total(total)
        total = total.to_f
        if discount_code.amount_type == "percentage"
          total - (total * (discount_code.amount.to_f / 100.0))
        else
          total - discount_code.amount.to_f * 100
        end
      end
    end
  end
end