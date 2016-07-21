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
            #next unless code.gift_card.current_value_in_cents > 0
            reduction_code_registers = applicable_registers(code)
            next unless reduction_code_registers.count > 0
            apply_reduction_code_registers(code, reduction_code_registers)
          end
        end

        def applicable_registers(code)
          @registers.select do |register|
            next false unless code.gift_card.organization_id == register.event.organization_id
            if code.gift_card.card_type == 'Package'
              next false if code.gift_card.remaining_tickets == 0
              # Check events in package against the ones in the register
              next true if gift_card_line_item_amount(register.event.id, register.line_items, code.gift_card)[:total] > 0
            end
            next true
          end
        end

        def apply_reduction_code_registers(code, registers)
          if code.gift_card.card_type == 'Package'
            @ticket_count = 0
            registers.each do |reg|
              discount = gift_card_line_item_amount(reg.event.id, reg.line_items, code.gift_card)
              if discount[:total] > 0
                reg.applied_reduction_codes.push({card: code, amount: discount[:total], type: :ticket, ticket_count: discount[:ticket_count]})
              end
            end
          else
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

        private
        def gift_card_line_item_amount(event_id, line_items, gift_card)
          # Figure out which ticket(s) are discounted and add up their cost and fees
          available_tickets = gift_card.remaining_tickets
          register_ticket_count = 0
          line_items_total = 0
          line_items.each do |item|
            gift_card.valid_events.select { |e| e[:event_id] == event_id }.each do |v|
              v[:ticket_types].each { |tt|
                if (tt['ticket_type_id'] == "" || item.entity.id == tt['ticket_type_id'].to_i) && (tt['price_level'] == "" || item.options['price_level'] == tt['price_level']) && @ticket_count < available_tickets
                  line_items_total += item.entity.price_for_level_in_cents_without_fee(item.options['price_level']) + item.entity.fee_for_level_in_cents(item.options['price_level'])
                  register_ticket_count += 1
                  @ticket_count += 1
                end
              }
            end
          end
          return {total: line_items_total, ticket_count: register_ticket_count}
        end
      end
    end
  end
end