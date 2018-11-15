module Tray
  module Models
    class PromoCodeCollection < Array
      def push(code)
        code = code.respond_to?(:id) ? PromoCode.new(discount_promo_code_id: code.id) : PromoCode.new(code)
        super(code)
      end

      def <<(code)
        push(code)
      end
    end
  end
end