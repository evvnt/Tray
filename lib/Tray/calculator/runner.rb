require_relative 'register'
require_relative 'discounter'
Dir[File.join(__dir__, 'adders', '*.rb')].each {|file| require file }
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

        discount(@registers)
        total
      end

      def total
        @registers.map(&:discounted_total).reduce(:+)
      end

      def total_for_org(org_id)
        @registers.select{|reg| reg.organization_id == org_id }.map(&:discounted_total).reduce(:+)
      end

      def ticket_fee_total_for_org(org_id)
        @registers.select{|reg| reg.organization_id == org_id }.map(&:ticket_fees_in_cents).reduce(:+)
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

      def discount(totals)
        Array(discounters).each {|kls| kls.call(@cart, totals)}
      end

      def discounters
        [
          Discounters::PromoCode,
          Discounters::Subscriptions,
          Discounters::Credits,
          Discounters::ReductionCode,
          Discounters::QuantityDiscount
        ]
      end

    end
  end
end
