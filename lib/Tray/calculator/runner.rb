require_relative 'register'
require_relative 'discounter'
Dir[File.join(__dir__, 'adders', '*.rb')].each {|file| require file }
Dir[File.join(__dir__, 'fees', '*.rb')].each {|file| require file }
Dir[File.join(__dir__, 'discounters', '*.rb')].each {|file| require file }

module Tray
  module Calculator
    class Runner
      attr_reader :registers
      def initialize(cart)
        @cart = cart
        call
        return self
      end

      def call
        @registers = add
        fees(@registers)
        discount(@registers)
        ticket_fees(@registers)
        total
      end

      def total
        @registers.map(&:discounted_total).reduce(0, :+) +
            @registers.map(&:ticket_fees_in_cents).sum +
            @registers.map(&:delivery_fee_in_cents).sum
      end

      def total_for_org(org_id)
        @registers.select{|reg| reg.organization_id == org_id }.map(&:discounted_total).reduce(0, :+)
      end

      # Gift cards and customer credits are payment methods, but are treated as discounts in many of the calculations
      # here. They should not reduce the taxable amount of the order, hence yet another method:
      def taxable_total_for_org(org_id)
        @registers.select{|reg| reg.organization_id == org_id }.map do |r|
          r.discounted_total + r.reduction_code_credit_total + r.customer_credits_total
        end.reduce(0, :+)
      end

      def ticket_fee_total_for_org(org_id)
        @registers.select{|reg| reg.organization_id == org_id }.map(&:ticket_fees_in_cents).reduce(0, :+)
      end

      def register_for_event(event_id)
        @registers.select{|reg| reg.event && reg.event.id == event_id}.first
      end

      def registers_by_package
        @registers.select{|reg| reg.package}
      end

      def line_items
        Tray::Models::LineItemCollection.new(@registers.map(&:line_items).flatten)
      end

      def add
        Array(adders).map {|kls| kls.call(@cart)}.flatten
      end

      def adders
        [
          Adders::Event,
          Adders::Package
        ]
      end

      def fees(totals)
        [
          Fees::ItemFee
        ].map {|kls| kls.call(@cart, totals)}
      end

      def discount(totals)
        Array(discounters).each {|kls| kls.call(@cart, totals)}
      end

      def discounters
        [
          Discounters::PromoCode,
          Discounters::Subscriptions,
          Discounters::QuantityDiscount,
          Discounters::Credits,
          Discounters::ReductionCode
        ]
      end

      def ticket_fees(totals)
        Fees::TicketFee.call(@cart, totals)
      end

    end
  end
end
