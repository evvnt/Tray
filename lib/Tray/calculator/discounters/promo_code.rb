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
              next true if code.discount_code.event_ids.length > 0 && code.discount_code.event_ids.include?(register.event.id) && Array(code.discount_code.applicable_events[register.event.id.to_s] & register.line_items.map(&:product_id)).length > 0
              next true if code.discount_code.event_ids.length == 0 && code.discount_code.organization_id == register.event.organization_id && code.discount_code.applies_to_all_events
            end
            if register.package.present?
              next true if code.discount_code.ticket_package_ids.length > 0 && code.discount_code.ticket_package_ids.include?(register.package.product_id)
            end
            next false
          end
        end

        def apply_code_registers(code, registers)
          if code.discount_code.percentage?
            registers.each do |reg|
              discount = percent_discount_in_cents_by_line_item(reg.line_items, code.discount_code)
              reg.applied_codes.push({code: code, amount: discount, description: code.discount_code.amount, type: :percentage})
            end
          else
            code_amount = [discountable_amount_by_line_item(registers, code.discount_code), (code.discount_code.amount.to_f * 100.0)].min
            registers.each do |reg|
              discount    = reg.line_items_total - [code_amount, 0].max
              discount    = reg.line_items_total - discount
              code_amount = code_amount - discount
              reg.applied_codes.push({code: code, amount: discount, description: discount, type: :credit})
            end
          end
        end

        private
        def percent_discount_in_cents_by_line_item(line_items, discount_code)
          return 0 unless discount_code.percentage?
          discount = 0
          line_items.each do |item|
            if code_applies_to_item?(discount_code, item)
              price = entity_price(item)
              discount += price * ([discount_code.amount.to_i, 0].max.to_f * 0.01)
            end
          end
          return discount
        end

        def discountable_amount_by_line_item(registers, discount_code)
          return discount_code.amount.to_f * 100.0 if discount_code.applies_to_all_events
          total = 0
          registers.each do |reg|
            reg.line_items.each do |item|
              total += entity_price(item) if code_applies_to_item?(discount_code, item)
            end
          end
          return total
        end

        def code_applies_to_item?(discount_code, item)
          code_applies_to_ticket?(discount_code, item) || code_applies_to_package?(discount_code, item)
        end

        def code_applies_to_ticket?(discount_code, item)
          return false unless item.product_model == :ticket
          discount_code.applies_to_all_events || discount_code.applicable_events.include?(item.entity.event_id) && discount_code.applicable_events[item.entity.event_id].include?(item.entity.id)
        end

        def code_applies_to_package?(discount_code, item)
          return false unless item.product_model == :ticket_package
          discount_code.applicable_packages.include?(item.product_id)
        end

        def entity_price(item)
          return item.entity.price_for_level_in_cents_without_fee(item.options[:price_level]) + item.entity.fee_for_level_in_cents(item.options[:price_level]) || 0 if item.product_model == :ticket
          return item.entity.price_in_cents + item.entity.package_fee_in_cents || 0 if item.product_model == :ticket_package
        end

      end
    end
  end
end