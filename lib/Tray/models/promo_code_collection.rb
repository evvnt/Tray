module Tray
  module Models
    class PromoCodeCollection < Array
      def push(code)
        code = code.is_a?(DiscountCode) ? PromoCode.new(discount_code_id: code.id) : PromoCode.new(code)
        super(code)
      end

      def <<(code)
        push(code)
      end

      ##TODO
      def sorted
        self
      end
    end
  end
end