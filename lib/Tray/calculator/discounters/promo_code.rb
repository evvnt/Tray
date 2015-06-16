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
            next true if code.discount_code.event_ids.length > 0 && code.discount_code.event_ids.include?(register.event.id)
            next true if code.discount_code.event_ids.length == 0 && code.discount_code.organization_id == register.event.organization_id
          end
        end

        def apply_code_registers(code, registers)
          if code.discount_code.percentage?
            registers.each {|reg| reg.applied_codes.push({code: code, amount: code.discount_code.amount, type: :percentage})}
          else
            code_amount = code.discount_code.amount.to_f * 100.0
            
            registers.each do |reg|
              discount    = reg.line_items_total - [code_amount, 0].max
              discount    = reg.line_items_total - discount
              code_amount = code_amount - discount
              reg.applied_codes.push({code: code, amount: discount, type: :credit})
            end
          end
        end
      end
    end
  end
end