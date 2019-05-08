module Tray
  module Calculator
    module Fees
      class TicketFee
        class << self

          def call(cart, registers)
            registers.each do |reg|
              total_fees = 0
              reg.line_items.each do |item|
                if item.entity.is_a?(TicketType)
                  total_fees += item.entity.fee_for_amount_in_cents(item.entity.price_for_level_in_cents_without_fee(item.options[:price_level]) - item.discount_total)
                elsif item.entity.is_a?(TicketPackage)
                  total_fees += item.entity.package_fee_in_cents
                end
              end
              reg.ticket_fees = total_fees
            end
          end
        end
      end
    end
  end
end