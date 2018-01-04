module Tray
  module Models
    class QuantityDiscount
      include Virtus.model

      attribute :event_id, Integer
      attribute :discount_amount, Integer

      def apply_to_total(total)
        total.to_f - discount_amount.to_f * 100
      end

    end
  end
end
