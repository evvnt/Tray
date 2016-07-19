module Tray
  module Calculator
    module Discounters
      class ReductionCode < Discounter
        def call
          @cart.reduction_codes.each do |code|
            next unless code.gift_card.current_value_in_cents > 0
            reduction_code_registers = applicable_registers(code)
            next unless reduction_code_registers.count > 0
            apply_reduction_code_registers(code, reduction_code_registers)
          end
        end

        def applicable_registers(code)
          @registers.select do |register|
            # TODO: this will need to be more specific if there is a definition
            next true if code.gift_card.organization_id == register.event.organization_id
          end
        end

        def apply_reduction_code_registers(code, registers)
          # if code.gift_card.card_type = 'Package'
          #   # TODO
          # else
            card_amount = code.gift_card.current_value_in_cents.to_f * 100.0
            registers.each do |reg|
              if reg.line_items_total - card_amount >= 0
                discount = card_amount
              else
                discount = reg.line_items_total
              end
              card_amount = card_amount - discount
              reg.applied_reduction_codes.push({card: code, amount: discount})
            end
          # end
        end
      end
    end
  end
end