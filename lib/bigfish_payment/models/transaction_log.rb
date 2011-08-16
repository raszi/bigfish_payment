module BigfishPayment
  class TransactionLog < ::ActiveRecord::Base
    belongs_to :transaction, :class_name => 'BigfishPayment::Transaction', :foreign_key => 'bf_payment_transaction_id'

    def self.from_response(response)
      new(:code => response.code, :message => response.message, :response => response.content)
    end
  end
end
