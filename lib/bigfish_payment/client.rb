require 'httpclient'
require 'libxml'

module BigfishPayment
  # This Exception signals an invalid response from the Payment Gateway
  class InvalidResponse < RuntimeError
  end

  # This class represents a Response from the Payment Gateway
  class Response
    attr_reader :code, :message, :optional, :content

    def initialize(content)
      @content = content
      @code = nil
      @message = nil
      @optional = {}

      parser = LibXML::XML::Parser.string(content)
      document = parser.parse

      root = document.root
      raise InvalidResponse, "Root element #{root.name}" unless root.name.match(/Response/)

      root.each do |n|
        next unless n.element?

        case n.name
          when 'ResultCode'
            @code = n.content
          when 'ResultMessage'
            @message = n.content
          else
            @optional[n.name] = n.content
        end
      end

    end
  end

  # This class helps to work with the HTTP client
  class Client

    # The path to initialize action
    PATH_INIT = "Init"

    # The path to start action
    PATH_START = "Start"

    # The path to result action
    PATH_RESULT = "Result"

    # The path to close action
    PATH_CLOSE = "Close"

    # Initializes a new payment transaction
    def self.init(params)
      send_request(get_url(PATH_INIT, params))
    end

    # Starts the transaction
    def self.start(params)
      get_url(PATH_START, params)
    end

    # Gets the result of the transaction
    def self.result(params)
      send_request(get_url(PATH_RESULT, params))
    end

    # Closes the transaction
    def self.close(params)
      send_request(get_url(PATH_CLOSE, params))
    end

    private

    # Sends request to the selected URL and parses the response
    def self.send_request(url)
      client = get_client

      response = client.get(url)

      status = response.status
      raise InvalidResponse, "Invalid HTTP response: #{status}" unless status == 200

      content_type = response.contenttype
      raise InvalidResponse, "Invalid HTTP response, content-type #{content_type}" unless content_type == 'text/xml'

      content = response.content
      raise InvalidResponse, "Invalid HTTP response, zero length" unless content

      parse_response(content)
    end

    # Parses the XML response and returns with a Response
    def self.parse_response(content)
      begin
        Response.new(content)
      rescue LibXML::XML::Parser::ParseError
        raise InvalidResponse, "Could not parse XML"
      end
    end

    # Creates and configures a new HTTP client
    def self.get_client
      proxy = BIGFISH_CONFIG['proxy'] 

      case
        when proxy
          Rails.logger.debug("Using proxy")
          HTTPClient.new(proxy)
        else
          HTTPClient.new
      end
    end

    # Creates the URL to the Payment Gateway
    def self.get_url(path, params)
      "#{Config.get_url}/#{path}?#{params.to_query}"
    end
  end
end
