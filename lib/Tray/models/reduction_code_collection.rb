module Tray
  module Models
    class ReductionCodeCollection < Array
      def push(card)
        card = card.is_a?(GiftCard) ? ReductionCode.new(gift_card_id: card.id) : ReductionCode.new(card)
        super(card)
      end

      def <<(card)
        push(card)
      end
    end
  end
end