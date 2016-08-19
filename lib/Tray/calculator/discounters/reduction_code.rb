module Tray
  module Calculator
    module Discounters
      class ReductionCode < Discounter

        def initialize(cart, registers)
          @ticket_count = 0
          super(cart, registers)
        end

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
            next false unless code.gift_card.organization_id == register.event.organization_id
            next false if code.gift_card.event_exclusions.include?(register.event.id)
            next false if (code.gift_card.valid_range_start && code.gift_card.valid_range_start > Time.now) || (code.gift_card.valid_range_end && code.gift_card.valid_range_end < Time.now)
            next true
          end
        end

        def apply_reduction_code_registers(code, registers)
          card_amount = code.gift_card.current_value_in_cents
          registers.each do |reg|
            if reg.line_items_total - card_amount >= 0
              discount = card_amount
            else
              discount = reg.line_items_total
            end
            card_amount = card_amount - discount
            reg.applied_reduction_codes.push({card: code, amount: discount, type: :credit})
          end
        end

      end
    end
  end
end