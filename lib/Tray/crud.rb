module Tray
  module CRUD
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def connection
        $redis
      end

      def create
        _inst = new
        _inst.save
        return _inst
      end

      def find(id)
        json = connection.get([Cart::NAMESPACE, id].join(':'))
        return nil unless json.present?

        attributes = JSON.parse(json)
        new(attributes)
      end

      def find_or_create(id)
        return create if id.nil?
        find(id) || create
      end
    end


    ###########
    ###INSTANCE
    ###########
    def save
      self.updated_at = Time.now
      _result = connection.set storage_id, JSON.generate(as_json)
      return true if _result == "OK"
    end

    def destroy
      connection.del(storage_id)
    end

    private
    def connection
      self.class.connection
    end

    def storage_id
      [Cart::NAMESPACE, self.id].join(':')
    end
  end
end