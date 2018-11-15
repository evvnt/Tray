module Tray
  module Models
    class ReductionCode
      include Virtus.model
      attribute :gift_card_id, Integer

      def gift_card
        @gift_card ||= Cart::PRODUCT_KEYS.invert[:gift_card].find(gift_card_id)
      end

    end
  end
end