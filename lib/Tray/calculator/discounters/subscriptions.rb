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
            next true if subscription.organization_id == register.event.organization_id && register.event.memberships_apply
          end
        end

        def apply_discount_subscription_registers(subscription, registers)
          amount = subscription.membership.amount.to_f * 100.0
          registers.each {|reg| reg.applied_subscriptions.push({subscription: subscription, amount: amount, type: :percentage})}
        end

        def apply_fixed_subscription_registers(subscription, registers)
          amount = subscription.membership.amount.to_i
          registers.each {|reg| reg.applied_subscriptions.push({subscription: subscription, amount: amount, type: :fixed})}
        end
      end
    end
  end
end