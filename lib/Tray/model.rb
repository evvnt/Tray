require_relative 'crud'
require_relative 'calculations'
require_relative 'orm'
require_relative 'models/reduction_code'
require_relative 'models/reduction_code_collection'
require_relative 'models/line_item'
require_relative 'models/line_item_collection'
require_relative 'models/promo_code'
require_relative 'models/promo_code_collection'
require_relative 'models/quantity_discount'
require_relative 'models/quantity_discount_collection'
require_relative 'calculator/runner'

module Tray
  class Model
    include Tray::CRUD
    include Tray::Calculations
    include Tray::ORM

    include Virtus.model

    NAMESPACE = "tray_cart"

    attribute :id, Integer, default: -> _, attribute {UUID.generate}
    attribute :line_items, Models::LineItemCollection[Models::LineItem], default: []
    attribute :promo_codes, Models::PromoCodeCollection[Models::PromoCode], default: []
    attribute :reduction_codes, Models::ReductionCodeCollection[Models::ReductionCode], default: []
    attribute :quantity_discounts, Models::QuantityDiscountCollection[Models::QuantityDiscount], default: []
    attribute :created_at, DateTime, default: -> _, attribute {Time.now}
    attribute :updated_at, DateTime, default: -> _, attribute {Time.now}
    attribute :payment_method_id, Integer
    attribute :shipping_address_id, Integer
    attribute :customer_id, Integer
    attribute :guest_configuration, Hash, default: {}
    attribute :errors, Array, default: []
    attribute :guest_card, Hash, default: {}

    def shipping_address
      return unless shipping_address_id
      @shipping_address ||= ShippingAddress.find(shipping_address_id)
    end

    def payment_method
      return unless payment_method_id
      @payment_method ||= PaymentMethod.find(payment_method_id)
    end

    def customer
      return unless customer_id
      @customer ||= Customer.find(customer_id)
    end

    def add_error(error_msg)
      errors.push(error_msg)
    end

  end
end
