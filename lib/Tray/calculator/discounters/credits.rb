module Tray
  module Calculator
    module Discounters
      class Credits < Discounter
        def call
          return unless @cart.customer
          @cart.customer.credits.sort_by(&:created_at).each do |credit|
            next unless credit.is_available?
            credit_registers = applicable_registers(credit)
            next unless credit_registers.count > 0

            apply_credit_registers(credit, credit_registers)
          end
        end

        def applicable_registers(credit)
          @registers.select do |register|
            next true if credit.organization_id == register.event.organization_id
          end
        end

        def apply_credit_registers(credit, registers)
          credit_amount = credit.amount_remaining_in_cents
          
          registers.each do |reg|
            discount    = ([credit_amount, 0].max - reg.line_items_total).abs
            discount    = reg.line_items_total - discount
            credit_amount = credit_amount - discount
            reg.applied_credits.push({credit: credit, amount: discount, type: :credit})
          end

        end
      end
    end
  end
end