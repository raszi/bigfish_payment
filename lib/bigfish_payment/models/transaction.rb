module BigfishPayment

  class Status
    PENDING    = /^PEND/
    SUCCESSFUL = /^SUCC/
    ERROR      = /^ERR/
    CANCELLED  = /^CANC/
  end

  class Transaction < ::ActiveRecord::Base

    has_many :logs, :class_name => 'BigfishPayment::TransactionLog', :dependent => :destroy, :foreign_key => 'bf_payment_transaction_id'
    belongs_to :currency, :class_name => 'BigfishPayment::Currency', :foreign_key => 'bf_payment_currency_id'
    belongs_to :provider, :class_name => 'BigfishPayment::Provider', :foreign_key => 'bf_payment_provider_id'

    #validates_presence_of :provider
    validates_presence_of :response_url

    # Initializes the transaction
    def init
      raise RuntimeError, "Could not initialize transaction without amount" unless self.respond_to?(:amount)

      raise RuntimeError, "Could not initialize transaction without response_url" unless self.response_url
      raise RuntimeError, "Could not initialize transaction, already initialized" if self.transaction_id?

      params = {
        :ProviderName => self.provider.code,
        :StoreName    => Config.get_store_name,
        :Amount       => self.amount,
        :Currency     => self.currency.code,
        :ResponseUrl  => self.response_url
      }

      # if somebody extended us, we should send this as well
      params[:UserId] = self.user_id if self.respond_to?(:user_id)
      params[:OrderId] = self.order_id if self.respond_to?(:order_id)

      response = Client.init(params)

      t_id = response.optional['TransactionId']
      if t_id
        self.transaction_id = t_id
      end

      log = TransactionLog.from_response(response)
      self.logs << log
      raise RuntimeError, "Could not update the Transaction: #{self.errors.full_messages}" unless self.save

      log.code.match(Status::SUCCESSFUL)
    end

    # Starts the transaction
    def start
      raise RuntimeError, "Could not start an uninitialized transaction" unless transaction_id?

      params = {
        :TransactionId => self.transaction_id
      }

      Client.start(params)
    end

    def result
      params = {
        :TransactionId => self.transaction_id
      }

      response = Client.result(params)

      # validating
      optional = response.optional
      raise RuntimeError, "Invalid response: TransactionId: #{optional['TransactionId']}" unless optional['TransactionId'] == self.transaction_id

      # double check if possible
      if self.respond_to?(:order_id)
        raise RuntimeError, "Invalid response: OrderId: #{optional['OrderId']}" unless optional['OrderId'] == self.order_id.to_s
      end

      if self.respond_to?(:user_id)
        raise RuntimeError, "Invalid response: UserId: #{optional['UserId']}" unless optional['UserId'] == self.user_id.to_s
      end

      log = TransactionLog.from_response(response)
      self.logs << log
      raise RuntimeError, "Could not update the Transaction: #{self.errors.full_messages}" unless self.save

      log.code
    end

  end
end
