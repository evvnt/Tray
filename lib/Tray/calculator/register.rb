module Tray
  module Calculator
    class Register
      include Virtus.model

      attribute :event
      attribute :package
      attribute :line_items, Tray::Models::LineItemCollection[Tray::Models::LineItem], default: []
      attribute :line_items_total, Integer, default: 0
      attribute :applied_codes, Array[Hash], default: []
      attribute :applied_credits, Array[Hash], default: []
      attribute :applied_subscriptions, Array[Hash], default: []
      attribute :applied_reduction_codes, Array[Hash], default: []
      attribute :applied_quantity_discount_amount, Integer, default: 0

      def discounted_total
        ttl_with_delivery_fee = line_items_total + delivery_fee_in_cents
        ttl_less_credits = ttl_with_delivery_fee - customer_credits_total - promo_code_total
        ttl_less_membership = ttl_less_credits - membership_discount_total
        ttl_less_quantity_discount = ttl_less_membership - quantity_discount_total
        ttl_less_reduction = ttl_less_quantity_discount - reduction_code_credit_total
        #Totals Can't Go Negative
        [ttl_less_reduction, 0.0].max
      end

      def ticket_fees_in_cents
        return package.entity.package_fee_in_cents if package.present?
        line_items.reduce(0) do |memo, item|
          ticket_fee = item.entity.fee_for_level_in_cents(item.options[:price_level])
          memo += ticket_fee * (item.quantity || 1)
        end
      end

      def delivery_method
        line_items.first.options[:delivery_method]
      end

      def delivery_fee_in_cents
        line_items.first.delivery_fee
      end

      # Total customer credit available
      def customer_credits_total
        applied_credits.map {|h| h[:amount] }.flatten.reduce(:+).to_i
      end

      # Total reduction code credit
      def reduction_code_credit_total
        applied_reduction_codes.map {|h| h[:amount]}.flatten.reduce(:+).to_i
      end

      # Total promo code discount
      def promo_code_total
        promo_code_credit_total + promo_code_percent_total
      end

      # Total discount amount from $ based promo codes
      def promo_code_credit_total
        applied_codes.select {|h| h[:type] == :credit}.map {|h| h[:amount] }.flatten.reduce(:+).to_i || 0
      end

      # Total discount amount from % based promo codes (Calculated in Discounters::PromoCode)
      def promo_code_percent_total
        applied_codes.select {|h| h[:type] == :percentage}.map {|h| h[:amount] }.flatten.reduce(:+).to_i || 0
      end

      # Totals membership discount amount
      def membership_discount_total
        membership_fixed_total + membership_percent_total
      end

      def quantity_discount_total
        applied_quantity_discount_amount
      end

      # Membership discount $ amounts
      def membership_fixed_total
        applied_subscriptions.select {|h| h[:type] == :fixed}.map {|h| h[:amount] }.flatten.reduce(:+).to_i || 0
      end

      # Membership discount % amounts (calculated in Discounters::Subscriptions)
      def membership_percent_total
        applied_subscriptions.select {|h| h[:type] == :percentage}.map {|h| h[:amount] }.flatten.reduce(:+).to_i || 0
      end

      def organization_id
        return package.entity.organization_id if package.present?
        event.organization_id
      end

    end
  end
end
