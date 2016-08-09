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

      def discounted_total
        ttl_with_delivery_fee = line_items_total + delivery_fee_in_cents
        ttl_less_credits = ttl_with_delivery_fee - credit_discount - reduction_code_credit_total
        ttl_less_percent = ttl_less_credits - (ttl_less_credits * ([percent_discount, 0].max.to_f * 0.01))
        #Totals Can't Go Negative
        [ttl_less_percent, 0.0].max
      end

      def bare_ticket_cost
        line_items.reduce(0) do |memo, item|
          ticket_price = item.entity.price_for_level_in_cents(item.options[:price_level])
          memo += ticket_price * (item.quantity || 1)
        end
      end

      def delivery_method
        line_items.first.options[:delivery_method]
      end

      def delivery_fee_in_cents
        line_items.first.delivery_fee
      end

      # Call and sum all fixed amount discounts
      def credit_discount
        promo_code_credit_total + promo_code_percent_total + customer_credits_total + membership_fixed_total
      end

      def customer_credits_total
        applied_credits.map {|h| h[:amount] }.flatten.reduce(:+).to_i
      end

      def promo_code_credit_total
        applied_codes.select {|h| h[:type] == :credit}.map {|h| h[:amount] }.flatten.reduce(:+).to_i
      end

      def reduction_code_credit_total
        applied_reduction_codes.map {|h| h[:amount]}.flatten.reduce(:+).to_i
      end

      def promo_code_percent_total
        # This is a percentage based discount, but we're calculating it when populating `applied_codes` since it can be filtered on the line item level
        # Keeping this a separate method for clarity
        applied_codes.select {|h| h[:type] == :percentage}.map {|h| h[:amount] }.flatten.reduce(:+).to_i
      end

      def membership_fixed_total
        applied_subscriptions.select {|h| h[:type] == :fixed}.map {|h| h[:amount] }.flatten.reduce(:+).to_i
      end

      # Call and sum all percentage based discounts
      def percent_discount
        membership_discount_total
      end

      def membership_discount_total
        applied_subscriptions.select {|h| h[:type] == :percentage}.map {|h| h[:amount] }.flatten.reduce(:+).to_i
      end

    end
  end
end