module Tray
  module Calculations
    def subtotal_in_cents
      subtotal = line_items.reduce(0) do |memo, item|
        memo += item.entity.price_in_cents * item.quantity
      end

      subtotal
    end

    def total_in_cents
      subtotal = subtotal_in_cents
      promo_codes.sorted.each do |code|
        next unless code.discount_code
        subtotal = code.apply_to_total(subtotal)
      end

      subtotal
    end

    def subtotal
      subtotal_in_cents.to_f / 100.0
    end

    def total
      total_in_cents.to_f / 100.0
    end

    def item_count
      line_items.count
    end
  end
end