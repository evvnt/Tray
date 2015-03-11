require_relative 'crud'
require_relative 'calculations'
require_relative 'orm'
require_relative 'models/line_item'
require_relative 'models/line_item_collection'
require_relative 'models/promo_code'
require_relative 'models/promo_code_collection'

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
    attribute :created_at, DateTime, default: -> _, attribute {Time.now}
    attribute :updated_at, DateTime, default: -> _, attribute {Time.now}
    attribute :payment_method_id, Integer
    attribute :shipping_address_id, Integer

    def shipping_address
      return unless shipping_address_id
      @shipping_address ||= ShippingAddress.find(shipping_address_id)
    end


  end
end