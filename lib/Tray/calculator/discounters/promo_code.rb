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
              next true if code.event_ids.length > 0 && code.event_ids.include?(register.event.id) && Array(code.applicable_events[register.event.id.to_s] & register.line_items.map(&:product_id)).length > 0
              next true if code.event_ids.length == 0 && code.organization_id == register.event.organization_id && code.applies_to_all_events
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
              discount += discount_code.calc_discount(price)
            end
          end
          discount
        end

        def code_applies_to_item?(discount_code, item)
          code_applies_to_ticket?(discount_code, item)
        end

        def code_applies_to_ticket?(discount_code, item)
          return false unless item.product_model == :ticket
          discount_code.applies_to_all_events || discount_code.applicable_events.include?(item.entity.event_id) && discount_code.applicable_events[item.entity.event_id].include?(item.entity.id)
        end

        def entity_price(item)
          item.entity.price_for_level_in_cents_without_fee(item.options[:price_level]) || 0 if item.product_model == :ticket
        end

      end
    end
  end
end