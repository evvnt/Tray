module Tray
  module Calculator
    module Fees
      class TicketFee
        class << self

          def call(cart, registers)
            registers.each do |reg|
              total_fees = 0
              reg.line_items.each do |item|
                entity = item.entity
                entity = entity.ticket_type if entity.is_a?(EventTicketType)

                if entity.respond_to?(:processing_fee)
                  total_fees += entity.processing_fee(entity.price_for_level_in_cents_without_fee(item.options[:price_level]) - item.discount_total)
                elsif entity.is_a?(TicketPackage)
                  total_fees += entity.package_fee_in_cents
                elsif entity.is_a?(Membership) || entity.is_a?(GiftCard)
                  total_fees += entity.fee_in_cents
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
