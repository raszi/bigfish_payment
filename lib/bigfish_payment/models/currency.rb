module BigfishPayment
  class Currency < ::ActiveRecord::Base
    extend Helpers::GetObject

    has_many :transactions, :class_name => 'BigfishPayment::Transaction', :dependent => :destroy, :foreign_key => 'bf_payment_currency_id'

    # Gets the Currency code by the instance, id or code itself
    def self.get(param)
      get_object(self, param)
    end

  end
end
