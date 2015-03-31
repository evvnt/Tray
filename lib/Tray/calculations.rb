module Tray
  module Calculations
    def subtotal_in_cents
      subtotal = event_subtotal_in_cents
      subtotal
    end

    def total_in_cents
      [
        :event_subtotal_with_discounts_in_cents, 
        :membership_subtotal_in_cents, 
        :donation_subtotal_in_cents
      ].map {|meth| method(meth).call}.sum
    end

    def subtotal
      total_in_cents.to_f / 100.0
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
      total = 0
      total_by_org = line_items.by_organization.each do |org_id, tickets|
        organization_total = 0
        tickets.group_by {|i| i.entity.event_id }.reduce do |event_id, event_tickets|
          event_total = event_tickets.reduce(0) do |memo, item|
            ticket_price   = item.entity.price_for_level_in_cents(item.options[:price_level])
            total = ticket_price * item.quantity
          end
          
          #Promo Codes
          promo_codes.sorted.each do |code|
            next unless code.discount_code
            event_total = code.apply_to_total(event_id, event_total)
          end

          organization_total += event_total
        end#End Event
        total += organization_total
      end#End Organization

      return total
    end
  end
end

#Calculation Order:
# 1) Events.
# 2) Discounts.
# 3) Memberships.
# 4) Donations.