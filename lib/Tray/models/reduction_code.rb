module Tray
  module Models
    class ReductionCode
      include Virtus.model
      attribute :gift_card_id, Integer

      def gift_card
        @gift_card ||= Cart::PRODUCT_KEYS.invert[:gift_card].find(gift_card_id)
      end

      def apply_to_total(total)
        total = total.to_f
        if @gift_card.card_type == 'Package'
          # TODO
        else
          [(total - gift_card.current_amount_in_cents.to_f * 100), 0].max
        end
      end

    end
  end
end