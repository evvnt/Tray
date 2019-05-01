module Tray
  module Calculations

    def subtotal_in_cents
      [
          :event_subtotal_in_cents,
          :ticket_packages_subtotal_in_cents
      ].concat(tag_ons_subtotal_method_array).map { |meth| method(meth).call }.sum
    end

    def total_in_cents
      [
          :subtotal_with_discounts_in_cents
      ].concat(tag_ons_subtotal_method_array).map { |meth| method(meth).call }.sum
    end

    def tag_ons_subtotal_method_array
      [
          :membership_subtotal_in_cents,
          :donation_subtotal_in_cents,
          :gift_card_subtotal_in_cents
      ]
    end

    def subtotal
      subtotal_in_cents.to_f / 100.0
    end

    def total
      total_in_cents.to_f / 100.0
    end

    def fees
      (ticket_fees_in_cents.to_f / 100.0) + (delivery_fees_in_cents.to_f / 100.0) + (ticket_package_fees_in_cents.to_f / 100.0)
    end

    def credits_available_in_cents
      return 0 unless customer_id
      customer.credits_available_in_cents
    end

    def item_count
      line_items.select(&:valid?).count
    end

    # For creating the order - return actual ticket fees
    def ticket_fees_in_cents
      line_items.by_ticket.reduce(0) do |memo, item|
        ticket_price = item.entity.fee_for_level_in_cents(item.options[:price_level], item.discount_total)
        memo += ticket_price * (item.quantity || 1)
      end
    end

    # For displaying the order - return ticket fees only event is set to show them
    def customer_ticket_fees_in_cents
      runner.line_items.by_ticket.reduce(0) do |memo, item|
        if item.entity.event.show_fees_to_customer?
          ticket_price = item.entity.fee_for_level_in_cents(item.options[:price_level], item.discount_total)
          memo += ticket_price * (item.quantity || 1)
        else
          memo += 0
        end
      end
    end

    def delivery_fees_in_cents
      event_fees = line_items.by_event.values.reduce(0) do |memo, items|
        memo += items.first.delivery_fee
      end
      event_fees + ticket_packages_mail_fees_in_cents
    end

    def customer_ticket_package_fees_in_cents
      line_items.by_ticket_package.reduce(0) do |memo, package|
        if package.entity.show_fees_to_customer?
          memo += package.entity.package_fee_in_cents
        else
          memo += 0
        end
      end
    end

    def ticket_package_fees_in_cents
      line_items.by_ticket_package.reduce(0) { |memo, package| memo += package.entity.package_fee_in_cents }
    end

    def membership_discount_total
      total = runner.registers.map(&:membership_discount_total).reduce(:+) || 0
      [total, subtotal_in_cents].min
    end

    def gift_card_discount_total_in_cents
      runner.registers.map(&:reduction_code_credit_total).reduce(:+) || 0
    end

    def quantity_discount_total_in_cents
      runner.registers.map(&:quantity_discount_total).reduce(:+) || 0
    end

    def item_fees_in_cents
      runner.registers.map(&:item_fees_in_cents).reduce(:+).to_i || 0
    end

    def item_fees
      item_fee_total = 0
      item_fees = Hash.new(0)
      runner.registers.map(&:applied_item_fees).flatten.each do |fee|
        item_fee_total += fee[:total_in_cents].to_i
        fee[:fees].each do |name, amount|
          item_fees[name] += amount.to_i
        end
      end
      OpenStruct.new(total_in_cents: item_fee_total, fees: item_fees)
    end

    def runner
      @runner ||= Tray::Calculator::Runner.new(self)
    end

    def event_subtotal_in_cents
      runner.line_items.by_ticket.reduce(0) do |memo, item|
        ticket_price = item.entity.price_for_level_in_cents(item.options[:price_level]) - item.discount_total
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

    def ticket_packages_subtotal_in_cents
      line_items.by_ticket_package.reduce(0) do |memo, item|
        memo += (item.entity.customer_price_in_cents || 0).to_i
      end
    end

    def gift_card_subtotal_in_cents
      line_items.by_gift_card.reduce(0) do |memo, item|
        memo += (item.entity.purchase_price_in_cents || 0).to_i
      end
    end

    def ticket_packages_in_cents
      line_items.by_ticket_package.reduce(0) do |memo, item|
        memo += (item.entity.price_in_cents || 0).to_i
      end
    end

    def ticket_packages_mail_fees_in_cents
      line_items.by_ticket_package.reduce(0) do |memo, item|
        next memo unless item.options[:delivery_method].to_s == "mail"
        memo += item.entity.mailing_fee_in_cents
      end
    end

    def subtotal_with_discounts_in_cents
      Tray::Calculator::Runner.new(self).call || 0
    end

  end
end

#Calculation Order:
# 1) Events.
# 2) Discounts.
# 3) Memberships.
# 4) Donations.
