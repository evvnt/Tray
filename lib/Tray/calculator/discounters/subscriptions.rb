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
            register_discount = 0
            # give the percent discount to each line item
            reg.line_items.each do |item|
              discount = (item.entity.price_for_level_in_cents_without_fee(item.options[:price_level]) * amount).round(0).to_i
              item.applied_discount_amounts.push({source: "Membership Discount", amount: discount})
              register_discount += discount
            end
            # inform the register of the total discount
            reg.applied_subscriptions.push({subscription: subscription, amount: register_discount, description: "#{(amount * 100.0)}%", type: :percentage})
          }
        end

        def apply_fixed_subscription_registers(subscription, registers)
          amount = subscription.membership.amount.to_i
          registers.each {|reg|
            # apply the discount across the items in proportion (same way backend does it)
            item_price_array = reg.line_items.map{|item| item.entity.price_for_level_in_cents_without_fee(item.options[:price_level])}
            discount_array = weighted_results(amount, item_price_array)
            reg.line_items.each_with_index do |item, index|
              item.applied_discount_amounts.push({source: "Membership Discount", amount: discount_array[index]})
            end

            reg.applied_subscriptions.push({subscription: subscription, amount: amount, description: amount, type: :fixed})
          }
        end

        private
        def weighted_results(total, weighted_array)
          weighted_sum = weighted_array.sum
          amounts = weighted_array.map do |item|
            weighted_sum == 0 ? 0 : (total * item.to_f/weighted_sum).to_i
          end
          amounts[-1] += total - amounts.sum if amounts[-1]
          amounts
        end
      end
    end
  end
end