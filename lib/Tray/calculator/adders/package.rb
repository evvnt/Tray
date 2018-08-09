module Tray
  module Calculator
    module Adders
      class Package
        class << self

          def call(cart)
            totals = []
            cart.line_items.by_ticket_package.each do |package|
              totals.push Tray::Calculator::Register.new(package: package, line_items_total: package.entity.price_in_cents + package.entity.package_fee_in_cents, line_items: package)
            end

            return totals
          end

        end
      end
    end
  end
end