module Tray
  module Models
    class PromoCode
      include Virtus.model

      attribute :discount_promo_code_id, Integer

      def discount_promo_code
        @discount_promo_code ||= Cart::PRODUCT_KEYS.invert[:discount].find(discount_promo_code_id)
      end

      def calc_discount(amount_in_cents)
        if percentage?
          amount = BigDecimal(discount_promo_code.percentage * amount_in_cents) / BigDecimal(100)
          rounded = amount.round(0, :banker)
          rounded.to_i
        else
          return amount_in_cents unless discount_promo_code.amount_in_cents < amount_in_cents
          discount_promo_code.amount_in_cents
        end
      end

      def applies_to_all_events
        discount_promo_code.applies_to_all_events
      end

      def event_ids
        discount_promo_code.event_ids
      end

      def ticket_type_ids
        discount_promo_code.ticket_type_ids
      end

      def organization_id
        discount_promo_code.organization_id
      end

      def percentage?
        discount_promo_code.calc_type == "percentage"
      end

      def percentage
        discount_promo_code.percentage
      end

      def amount_in_cents
        discount_promo_code.amount_in_cents
      end

    end
  end
end