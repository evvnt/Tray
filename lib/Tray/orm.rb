module Tray
  module ORM
    def add(item, quantity = 1, options = {})
      product_model = Cart::PRODUCT_KEYS[item.class]
      line_items.push(product_model: product_model, product_id: item.id, quantity: quantity, options: options)
    end

    def remove(product_model, product_id, options = {})
      line_items.decrement(product_model, product_id)
    end

    def empty
      line_items.clear
      promo_codes.clear
    end

    def update_delivery_method(options = {})
      if options[:ticket_package_id].present?
        puts options[:ticket_package_id]
        line_items.by_ticket_package.find {|li| li.id == options[:ticket_package_id]}.tap do |li|
          li_options = li.options.clone
          li_options[:delivery_method] = options[:delivery_method]
          li.options = li_options
        end
      else
        line_items.by_ticket.select {|li| li.entity.event_id == options[:event_id]}.each do |ticket|
          ticket_options = ticket.options.clone
          ticket_options[:delivery_method] = options[:delivery_method]
          ticket.options = ticket_options
        end
      end
    end
  end
end