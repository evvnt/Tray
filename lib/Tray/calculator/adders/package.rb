module Tray
  module Calculator
    module Adders
      class Package
        class << self

          def call(cart)
            totals = []
            cart.line_items.by_ticket_package.each do |package|
              totals.push Tray::Calculator::Register.new(package: package, line_items_total: package.entity.customer_price_in_cents, line_items: package)
            end

            return totals
          end

          # def reduce_line_items(items)
          #   items.reduce(0) do |memo, item|
          #     package_price = item.entity.customer_price_in_cents
          #     #memo += package_price * (item.quantity || 1) # No quantities with packages yet
          #   end
          # end

        end
      end
    end
  end
end