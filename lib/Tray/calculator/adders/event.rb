module Tray
  module Calculator
    module Adders
      class Event
        class << self

          def call(cart)
            totals = []
            cart.line_items.by_event.each do |event, items|
              totals.push Tray::Calculator::Register.new(event: event, line_items_total: reduce_line_items(items), line_items: items)
            end

            return totals
          end

          def reduce_line_items(items)
            items.reduce(0) do |memo, item|
              ticket_price = item.entity.price_for_level_in_cents_without_fee(item.options[:price_level])
              ticket_price += item.entity.fee_for_level_in_cents(item.options[:price_level], item.discount_total)
              memo += ticket_price * (item.quantity || 1)
            end
          end

        end
      end
    end
  end
end