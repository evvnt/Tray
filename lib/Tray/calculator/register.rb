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
      attribute :applied_item_fees, Hash, default: {}
      attribute :ticket_fees, Integer, default: 0

      # The discounted total is the price of the tickets less credits and
      # discounts plus item fees.
      def discounted_total
        line_items = line_items_total
        fees = [item_fees_in_cents].sum
        credits = [customer_credits_total, promo_code_total].sum
        discounts = [membership_discount_total, quantity_discount_total].sum

        total = line_items + fees - credits - discounts
        [total, 0].max
      end

      def ticket_fees_in_cents
        return package.entity.package_fee_in_cents if package.present?
        ticket_fees
      end

      # The subtotal is the discounted total plus ticket fees.
      def subtotal
        fees = [ticket_fees_in_cents].sum

        discounted_total + fees
      end
      
      # The final total is the subtotal plus delivery fees less reductions.
      def final_total
        fees = [ticket_fees_in_cents, delivery_fee_in_cents].sum
        reductions = [reduction_code_credit_total].sum

        discounted_total + fees - reductions
      end

      def item_fees_in_cents
        (applied_item_fees[:total_in_cents] || 0).to_i
      end

      def delivery_method
        line_items.first.options[:delivery_method]
      end

      def delivery_fee_in_cents
        line_items.first.delivery_fee
      end

      # Total customer credit available
      def customer_credits_total
        applied_credits.map {|h| h[:amount]}.flatten.reduce(:+).to_i || 0
      end

      # Total reduction code credit
      def reduction_code_credit_total
        applied_reduction_codes.map {|h| h[:amount]}.flatten.reduce(:+).to_i || 0
      end

      # Total promo code discount
      def promo_code_total
        promo_code_credit_total + promo_code_percent_total
      end

      # Total discount amount from $ based promo codes
      def promo_code_credit_total
        applied_codes.select {|h| h[:type] == :credit}.map {|h| h[:amount]}.flatten.reduce(:+).to_i || 0
      end

      # Total discount amount from % based promo codes (Calculated in Discounters::PromoCode)
      def promo_code_percent_total
        applied_codes.select {|h| h[:type] == :percentage}.map {|h| h[:amount]}.flatten.reduce(:+).to_i || 0
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
