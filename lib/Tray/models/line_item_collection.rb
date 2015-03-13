module Tray
  module Models
    class LineItemCollection < Array
      def push(line_item)
        super(LineItem.new(line_item))
      end

      def <<(line_item)
        super(LineItem.new(line_item))
      end

      def by_ticket
        select {|li| li.product_model == :ticket}
      end

      def by_event
        by_ticket.group_by {|li| li.entity.event}
      end

      def by_membership
        select {|li| li.product_model == :membership}
      end

      def by_donation
        select {|li| li.product_model == :donation}
      end

      def quantity
        map(&:quantity).reduce(:+)
      end

      def decrement(model, id)
        item = find {|item| item.product_model == model && item.product_id == id}
        if item.quantity > 1
          item.quantity = item.quantity - 1
        else
          delete(item)
        end
      end
    end
  end
end