module Tray
  module Calculator
    module Discounters
      class ReductionCode < Discounter
        def call
          @cart.reduction_codes.each do |code|
            #next unless code.gift_card.current_value_in_cents > 0
            reduction_code_registers = applicable_registers(code)
            next unless reduction_code_registers.count > 0
            apply_reduction_code_registers(code, reduction_code_registers)
          end
        end

        def applicable_registers(code)
          @registers.select do |register|
            next true if code.gift_card.organization_id == register.event.organization_id
            if code.gift_card.card_type == 'Package'
              next false if code.gift_card.remaining_tickets == 0
              # Check events in package against the ones in the register
              next true if gift_card_line_item_amount(register.event.id, register.line_item, code.gift_card)
            end
          end
        end

        def apply_reduction_code_registers(code, registers)
          # if code.gift_card.card_type = 'Package'
          #   # TODO: make deductions from total based on ticket. Keep track of # of tickets and the associated discount amount. Decrements row will look like: [{amount: XXXX, ticket_count: XXXX, customer_order_id: XXXXX},...]
          #   - for each ticket, check type/price level
          #   - add to applied_reduction_codes with amount of ticket+fee and new type
          #     reg.applied_reduction_codes.push({card: code, amount: discount, type: :ticket, ticket_count: XX})  # -- each one of these should count as a deduction of one ticket in the card's record
          # else
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
          # end
        end

        private
        def gift_card_line_item_amount(event_id, line_item, gift_card)
          # TODO: finish this, look at cart model method
        end
      end
    end
  end
end