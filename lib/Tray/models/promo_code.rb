module Tray
  module Models
    class PromoCode
      include Virtus.model

      attribute :discount_code_id, Integer

      def discount_code
        @discount_code ||= Cart::PRODUCT_KEYS.invert[:discount].find(discount_code_id)
      end

      def apply_to_total(event_id, total)
        return total if discount_code.event_ids.length > 0 && !discount_code.event_ids.include?(event_id)
        return total if discount_code.event_ids.length == 0
        ##TODO: FINISH THIS /\

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