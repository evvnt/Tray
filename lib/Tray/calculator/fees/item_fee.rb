module Tray
  module Calculator
    module Fees
      class ItemFee
        class << self

          def call(cart, registers)
            registers.each do |reg|

              ticket_count = 0
              reg.line_items.each do |item|
                entity = item.entity
                entity = entity.ticket_type if entity.is_a?(EventTicketType)

                if entity.is_a?(TicketType)
                  ticket_count += 1
                elsif entity.is_a?(TicketPackage)
                  ticket_count += entity.ticket_quantity
                end
              end

              attribs = {totals_by_org: [{organization_id: reg.organization_id,
                                          event_id: reg.event.id,
                                          total_in_cents: taxable_total(reg),
                                          line_item_count: ticket_count}]}
              calculate_item_fees(cart, attribs, reg)
            end
          end

          def calculate_item_fees(cart, attribs, register)
            return unless cart.respond_to? :calculate_item_fees
            fees = cart.calculate_item_fees(attribs)
            register.applied_item_fees = fees
          end

          def taxable_total(reg)
            reg.discounted_total + reg.reduction_code_credit_total + reg.customer_credits_total
          end
        end
      end
    end
  end
end