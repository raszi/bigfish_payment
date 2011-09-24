  module BigfishPayment
    class Transaction < ::ActiveRecord::Base

      has_many :logs, :class_name => 'BigfishPayment::TransactionLog', :dependent => :destroy, :foreign_key => 'bf_payment_transaction_id'
      belongs_to :currency, :class_name => 'BigfishPayment::Currency', :foreign_key => 'bf_payment_currency_id'
      belongs_to :provider, :class_name => 'BigfishPayment::Provider', :foreign_key => 'bf_payment_provider_id'

      validates_presence_of :response_url
      validates_numericality_of :amount, :greater_than => 0

      # Initializes the transaction in the PHP way
      #
      # PHP equivalent:
      # <tt>$paymentGateway->init(’CIB’, ’http://www.webaruhaz.hu/payment_gateway_valasz_url.php’, ’1500’, ’12345’, ’123’, ’HUF’, ’HU’);</tt>
      def self.init(provider, response_url, amount, user_id=nil, currency='HUF', language='HU')
        t = new(:amount => amount, :response_url => response_url, :currency => Currency.get(currency), :provider => Provider.get(provider))

        t.user_id = user_id if t.respond_to?(:user_id)

        raise RuntimeError, "Could not create Transaction: #{t.errors.full_messages}" unless t.save

        t.init

        t
      end

      # Initializes the transaction
      def init
        raise RuntimeError, "Could not initialize transaction, already initialized" if transaction_id?

        params = {
          :ProviderName => self.provider.code,
          :StoreName    => Config.get_store_name,
          :Amount       => amount,
          :OrderId      => self.id,
          :Currency     => self.currency.code,
          :ResponseUrl  => self.response_url
        }

        # if somebody extended us, we should send this as well
        params[:UserId] = self.user_id if self.respond_to?(:user_id)

        response = Client.init(params)

        t_id = response.optional['TransactionId']
        if t_id
          self.transaction_id = t_id
        end

        self.logs << TransactionLog.from_response(response)
        raise RuntimeError, "Could not update the Transaction: #{self.errors.full_messages}" unless self.save
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
        raise RuntimeError, "Invalid response: OrderId: #{optional['OrderId']}" unless optional['OrderId'] == self.id.to_s

        if self.respond_to?(:user_id)
          raise RuntimeError, "Invalid response: UserId: #{optional['UserId']}" unless optional['UserId'] == self.user_id.to_s
        end

        self.logs << TransactionLog.from_response(response)
        raise RuntimeError, "Could not update the Transaction: #{self.errors.full_messages}" unless self.save
      end

  end
end
