module Tray
  module Calculations
    def subtotal_in_cents
      subtotal = event_subtotal_in_cents
      subtotal
    end

    def total_in_cents
      [
        :event_subtotal_with_discounts_in_cents, 
        :ticket_fees_in_cents,
        :membership_subtotal_in_cents, 
        :donation_subtotal_in_cents
      ].map {|meth| method(meth).call}.sum
    end

    def subtotal
      subtotal_in_cents.to_f / 100.0
    end

    def total
      total_in_cents.to_f / 100.0
    end

    def fees
      ticket_fees_in_cents.to_f / 100.0
    end

    def credits_available_in_cents
      return 0 unless customer_id
      customer.credits_available_in_cents
    end

    def item_count
      line_items.count
    end

    def ticket_fees_in_cents
      line_items.by_ticket.reduce(0) do |memo, item|
        next 0 unless item.entity.event.pass_fees_to_customer?
        ticket_price = item.entity.fee_for_level_in_cents(item.options[:price_level])
        memo += ticket_price * (item.quantity || 1)
      end
    end

    # private
    def event_subtotal_in_cents
      line_items.by_ticket.reduce(0) do |memo, item|
        ticket_price = item.entity.price_for_level_in_cents(item.options[:price_level])
        memo += ticket_price * item.quantity
      end
    end

    def membership_subtotal_in_cents
      line_items.by_membership.reduce(0) do |memo, item|
        memo += item.entity.price_in_cents.to_i
      end
    end

    def donation_subtotal_in_cents
      line_items.by_donation.reduce(0) do |memo, item|
        options = item.options.symbolize_keys
        memo += (options[:amount_in_cents] || 0).to_i
      end
    end

    def event_subtotal_with_discounts_in_cents
      Tray::Calculator::Runner.new(self).call || 0
    end
  end
end

#Calculation Order:
# 1) Events.
# 2) Discounts.
# 3) Memberships.
# 4) Donations.