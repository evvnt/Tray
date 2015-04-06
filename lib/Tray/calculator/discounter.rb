module Tray
  module Calculator
    class Discounter
      def self.call(cart, registers)
        new(cart, registers).call
      end

      def initialize(cart, registers)
        @cart = cart
        @registers = registers
      end
    end
  end
end