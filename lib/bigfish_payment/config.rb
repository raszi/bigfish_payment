module BigfishPayment

  # This class helps to work with the configuration parameters
  class Config

    # Gets the base URL of the Payment Gateway
    def self.get_url
      BIGFISH_CONFIG['url']
    end

    # Gets the name of the Store associated by the provider
    def self.get_store_name
      BIGFISH_CONFIG['store_name'].chomp("/")
    end

  end
end
