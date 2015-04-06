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
              ticket_price = item.entity.price_for_level_in_cents(item.options[:price_level])
              if item.entity.event.pass_fees_to_customer?
                ticket_price += item.entity.fee_for_level_in_cents(item.options[:price_level])
              end
              memo += ticket_price * (item.quantity || 1)
            end
          end

        end
      end
    end
  end
end