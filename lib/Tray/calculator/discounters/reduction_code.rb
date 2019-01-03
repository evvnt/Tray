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
            next true if applies_to_event(code, register)
            next true if applies_to_package(code, register)
            next false if (code.gift_card.valid_range_start && code.gift_card.valid_range_start > Time.now) || (code.gift_card.valid_range_end && code.gift_card.valid_range_end < Time.now)
            next false
          end
        end

        def applies_to_event(code, register)
          register.event.present? &&
            code.gift_card.organization_id == register.event.organization_id &&
              !code.gift_card.event_exclusions.include?(register.event.id)
        end

        def applies_to_package(code, register)
          register.package.present? && code.gift_card.organization_id == register.package.entity.organization_id
        end

        def apply_reduction_code_registers(code, registers)
          card_amount = code.gift_card.current_value_in_cents
          registers.each do |reg|
            # Calculate the $ amount of gift card used after discounts have been applied
            discount = [card_amount, reg.discounted_total].min
            card_amount = card_amount - discount
            reg.applied_reduction_codes.push({card: code, amount: discount, type: :credit})
          end
        end

      end
    end
  end
end