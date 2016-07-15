module Tray
  module Models
    class GiftCardCollection < Array
      def push(card)
        card = card.is_a?(GiftCard) ? GiftCard.new(gift_card_id: card.id) : GiftCard.new(card)
        super(card)
      end

      def <<(card)
        push(card)
      end
    end
  end
end