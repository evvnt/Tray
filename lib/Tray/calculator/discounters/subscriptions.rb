module Tray
  module Calculator
    module Discounters
      class Subscriptions < Discounter
        def call
          return unless @cart.customer
          @cart.customer.subscriptions.each do |subscription|
            next unless subscription.is_available?
            next unless subscription.discount? || subscription.fixed?

            _applicable_registers = applicable_registers(subscription)
            next unless _applicable_registers.count > 0

            if subscription.discount?
              apply_discount_subscription_registers(subscription, _applicable_registers)
            elsif subscription.fixed?
              apply_fixed_subscription_registers(subscription, _applicable_registers)
            end

          end
        end

        def applicable_registers(subscription)
          @registers.select do |register|
            next false if register.package.present?
            next true if subscription.organization_id == register.event.organization_id && register.event.memberships_apply
          end
        end

        def apply_discount_subscription_registers(subscription, registers)
          amount = subscription.membership.amount.to_f # * 100.0
          registers.each {|reg|
            total_discount = 0
            reg.line_items.each do |item|
              ticket_price = item.entity.price_for_level_in_cents_without_fee(item.options[:price_level])
              item.applied_discount_amounts.push({source: "Membership Discount", amount: (ticket_price * amount).to_i})
              total_discount += (ticket_price * amount).to_i
              # find difference between fee with and without discount, add to total_discount for register
              old_fee = item.entity.fee_for_level_in_cents(item.options[:price_level])
              new_fee = item.entity.fee_for_level_in_cents(item.options[:price_level], item.discount_total)
              total_discount += old_fee - new_fee
            end
            reg.applied_subscriptions.push({subscription: subscription, amount: total_discount, description: "#{(amount * 100.0)}%", type: :percentage})
          }
        end

        def apply_fixed_subscription_registers(subscription, registers)
          amount = subscription.membership.amount.to_i
          registers.each {|reg| reg.applied_subscriptions.push({subscription: subscription, amount: amount, description: amount, type: :fixed})}
        end

      end
    end
  end
end