module Tray
  module Calculator
    module Fees
      class ItemFee
        class << self

          def call(cart, registers)
            registers.each do |reg|
              attribs = {totals_by_org: [{organization_id: reg.organization_id, total_in_cents: taxable_total(reg), line_item_count: reg.line_items.length}]}
              calculate_item_fees(cart, attribs, reg)
            end
          end

          def calculate_item_fees(cart, attribs, register)
            return unless cart.respond_to? :calculate_item_fees
            fees = cart.calculate_item_fees(attribs)
            register.applied_item_fees = fees
          end

          def taxable_total(reg)
            reg.discounted_total + reg.reduction_code_credit_total + reg.customer_credits_total - reg.ticket_fees_in_cents
          end

        end
      end
    end
  end
end