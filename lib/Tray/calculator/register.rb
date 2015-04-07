module Tray
  module Calculator
    class Register
      include Virtus.model

      attribute :event
      attribute :line_items, Tray::Models::LineItemCollection[Tray::Models::LineItem], default: []
      attribute :line_items_total, Integer, default: 0
      attribute :applied_codes, Array[Hash], default: []
      attribute :applied_credits, Array[Hash], default: []
      attribute :applied_subscriptions, Array[Hash], default: []

      def discounted_total
        ttl_less_credits = line_items_total - credit_discount
        ttl_less_percent = ttl_less_credits - (ttl_less_credits * ([percent_discount, 0].max.to_f * 0.01))
        
        #Totals Can't Go Negative
        [ttl_less_percent, 0.0].max
      end

      def delivery_method
        line_items.first.options[:delivery_method]
      end

      def credit_discount
        promo_code_credit_total + customer_credits_total
      end

      def customer_credits_total
        applied_credits.map {|h| h[:amount] }.flatten.reduce(:+).to_i
      end

      def promo_code_credit_total
        applied_codes.select {|h| h[:type] == :credit}.map {|h| h[:amount] }.flatten.reduce(:+).to_i
      end

      def percent_discount
        codes_off = applied_codes.select {|h| h[:type] == :percentage}.map {|h| h[:amount] }.flatten.reduce(:+).to_i
        subscriptions_off = applied_subscriptions.select {|h| h[:type] == :percentage}.map {|h| h[:amount] }.flatten.reduce(:+).to_i
      
        codes_off + subscriptions_off
      end
    end
  end
end