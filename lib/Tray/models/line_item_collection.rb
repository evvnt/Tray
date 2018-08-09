module Tray
  module Models
    class LineItemCollection < Array
      def push(line_item)
        super(LineItem.new(line_item))
      end

      def <<(line_item)
        super(LineItem.new(line_item))
      end

      def find(id = nil)
        if block_given?
          super
        else
          super {|li| li.id == id}
        end
      end

      def by_ticket
        select {|li| li.product_model == :ticket}
      end

      def by_event
        by_ticket.group_by {|li| li.entity.event}
      end

      def by_organization
        map {|li| li.entity.organization_id }.uniq
      end

      def by_membership
        select {|li| li.product_model == :membership}
      end

      def by_donation
        select {|li| li.product_model == :donation}
      end

      def by_gift_card
        select {|li| li.product_model == :gift_card_definition}
      end

      def by_ticket_package
        select {|li| li.product_model == :ticket_package && li.valid?}
      end


      def quantity
        map(&:quantity).reduce(:+)
      end

      def decrement(model, id, seatId)
        if seatId.present?
          return delete(find {|item| item.product_model == model && item.product_id == id && item.options[:seat_id] == seatId })
        end

        if model === :ticket_package
          return delete_if {|item| item.product_model == model && item.product_id == id }
        end

        if item = find {|item| item.product_model == model && item.product_id == id}
          if item.quantity > 1
            item.quantity = item.quantity - 1
          else
            delete(item)
          end
        end
      end

    end
  end
end
