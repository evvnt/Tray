module Tray
  module Calculator
    module Discounters
      class QuantityDiscount < Discounter

        def call
          @cart.quantity_discounts.each do |qd|
            qd_registers = applicable_registers(qd)
            next unless qd_registers.count > 0
            apply_code_registers(qd, qd_registers)
          end
        end

        def applicable_registers(qd)
          @registers.select do |register|
            if register.event.present? && register.event.id == qd.event_id
              next true
            else
              next false
            end
          end
        end

        def apply_code_registers(qd, registers)
          clear_current_amounts(registers)
          registers.each do |reg|
            reg.applied_quantity_discount_amount += qd.discount_amount
          end
        end

        def clear_current_amounts(registers)
          registers.each { |reg| reg.applied_quantity_discount_amount = 0 }
        end

      end
    end
  end
end
