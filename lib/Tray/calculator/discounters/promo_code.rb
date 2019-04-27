module Tray
  module Calculator
    module Discounters
      class PromoCode < Discounter
        def call
          @cart.promo_codes.each do |code|
            promo_registers = applicable_registers(code)
            next unless promo_registers.count > 0

            apply_code_registers(code, promo_registers)
          end
        end

        def applicable_registers(code)
          @registers.select do |register|
            if register.event.present?
              next true if code.applies_to_all_events && code.organization_id == register.event.organization_id
              next true if code.event_restricted? && code.event_ids.include?(register.event.id)
              next true if code.ticket_restricted? && register.line_items.by_ticket.any? {|item| code.ticket_type_ids.include?(ticket_type_id(item.entity.id))}
            end
            next false
          end
        end

        def apply_code_registers(code, registers)
          registers.each do |reg|
            discount = discount_in_cents_by_line_item(reg.line_items, code)
            reg.applied_codes.push({code: code.discount_promo_code.code,
                                    amount: discount,
                                    description: discount,
                                    type: code.percentage? ? :percentage : :credit})
          end
        end

        private

        def discount_in_cents_by_line_item(line_items, discount_code)
          discount = 0
          line_items.each do |item|
            if code_applies_to_item?(discount_code, item)
              price = entity_price(item)
              fee = entity_fee(item)
              discount += discount_code.calc_discount(price) + discount_code.calc_fee_discount(fee)
            end
          end
          discount
        end

        def code_applies_to_item?(discount_code, item)
          code_applies_to_ticket?(discount_code, item)
        end

        def code_applies_to_ticket?(code, item)
          return false unless item.product_model == :ticket
          code.applies_to_all_events ||
              (code.event_restricted? && code.event_ids.include?(item.entity.event_id)) ||
              (code.ticket_restricted? && code.ticket_type_ids.include?(ticket_type_id(item.entity.id)))
        end

        def ticket_type_id(event_ticket_type_id)
          EventTicketType.find(event_ticket_type_id).ticket_type_id
        end

        def entity_price(item)
          item.entity.price_for_level_in_cents_without_fee(item.options[:price_level]) || 0 if item.product_model == :ticket
        end

        def entity_fee(item)
          item.entity.fee_for_level_in_cents(item.options[:price_level]) || 0 if item.product_model == :ticket
        end

      end
    end
  end
end