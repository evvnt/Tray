module Tray
  module Calculator
    module Discounters
      class Subscriptions < Discounter
        def call
          return unless @cart.customer
          @cart.customer.subscriptions.each do |subscription|
            next unless subscription.discount? && subscription.is_available?

            _applicable_registers = applicable_registers(subscription)
            next unless _applicable_registers.count > 0

            apply_subscription_registers(subscription, _applicable_registers)
          end
        end

        def applicable_registers(subscription)
          @registers.select do |register|
            next true if subscription.organization_id == register.event.organization_id
          end
        end

        def apply_subscription_registers(subscription, registers)
          amount = subscription.membership.amount.to_f * 100.0
          registers.each {|reg| reg.applied_subscriptions.push({subscription: subscription, amount: amount, type: :percentage})}
        end
      end
    end
  end
end