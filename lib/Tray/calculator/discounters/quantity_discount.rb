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
          discount_list = qd.ticket_discount_list
          registers.each do |reg|
            # apply the discount across the appropriate tickets
            reg.line_items.each do |item|
              # for each ticket, look in the ticket discount list to see if there is a discount that matches
              applicable = discount_list.select do |ticket_discount|
                ticket_discount[:ticket_type_id] == item.product_id && ticket_discount[:ticket_type_price_level_name] == item.options[:price_level]
              end
              if applicable.count > 0
                item.applied_discount_amounts << {source: "Quantity Discount", amount: applicable.first[:discount_amount]}
                discount_list.delete_at(discount_list.index(applicable.first))
              end
            end

            # inform the register as to the total
            reg.applied_quantity_discount_amount += qd.discount_amount
          end
        end


        def discount_applies_to_ticket?(qd, ticket)

        end

      end
    end
  end
end
