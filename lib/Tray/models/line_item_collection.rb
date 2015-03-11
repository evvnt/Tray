module Tray
  module Models
    class LineItemCollection < Array
      def push(line_item)
        super(LineItem.new(line_item))
      end

      def <<(line_item)
        super(LineItem.new(line_item))
      end

      def by_event
        self.select {|li| li.product_model == :ticket}.group_by {|li| li.entity.event}
      end

      def by_membership
        self.select {|li| li.product_model == :membership}
      end

      def quantity
        self.map(&:quantity).reduce(:+)
      end

      def decrement(model, id)
        item = self.find {|item| item.product_model == model && item.product_id == id}
        if item.quantity > 1
          item.quantity = item.quantity - 1
        else
          self.delete(item)
        end
      end
    end
  end
end