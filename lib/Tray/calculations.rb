module Tray
  module Calculations
    def subtotal_in_cents
      subtotal = event_subtotal_in_cents
      subtotal
    end

    def total_in_cents
      total = event_subtotal_with_discounts_in_cents
      total = total + membership_subtotal_in_cents
      total = total + donation_subtotal_in_cents
      return total
    end

    def subtotal
      subtotal_in_cents.to_f / 100.0
    end

    def total
      total_in_cents.to_f / 100.0
    end

    def item_count
      line_items.count
    end

    # private
    def event_subtotal_in_cents
      line_items.by_ticket.reduce(0) do |memo, item|
        memo += item.entity.price_in_cents * item.quantity
      end
    end

    def membership_subtotal_in_cents
      line_items.by_membership.reduce(0) do |memo, item|
        memo += item.entity.price_in_cents
      end
    end

    def donation_subtotal_in_cents
      line_items.by_membership.reduce(0) do |memo, item|
        memo += item.options.symbolize_keys[:amount_in_cents]
      end
    end

    def event_subtotal_with_discounts_in_cents
      subtotal = event_subtotal_in_cents
      promo_codes.sorted.each do |code|
        next unless code.discount_code
        subtotal = code.apply_to_total(subtotal)
      end
      subtotal
    end
  end
end

#Calculation Order:
# 1) Events.
# 2) Discounts.
# 3) Memberships.
# 4) Donations.