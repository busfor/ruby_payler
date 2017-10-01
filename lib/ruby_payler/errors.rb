module RubyPayler
  # Base error class for all RubyPayler errors
  # Every RubyPayler Error Class must have code, message and to_s methods!
  class Error < RuntimeError
  end

  # Response.body contains error
  class ResponseError < Error
    attr_reader :response

    def initialize(response)
      @response = response
    end

    # Payler error code
    def code
      response_error.code
    end

    # Payler error description
    def message
      response_error.message
    end

    def to_s
      "Payler responded with error: #{message}, code #{code}"
    end

    private

    def response_error
      @response_error ||= response.body.error
    end
  end

  # Unexpected response
  class UnexpectedResponseError < Error
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def code
      @code ||= response.status
    end

    def body
      @body ||= response.body
    end

    def message
      "Unexpected response: code - #{code}, body - #{body}"
    end

    def to_s
      message
    end
  end

  # Network Error (Faraday exception)
  class NetworkError < Error
    def initialize(faraday_error)
      @faraday_error = faraday_error
    end

    def code
      'NetworkError'
    end

    def message
      @faraday_error.inspect
    end

    def to_s
      "NetworkError occured while performing request to Payler: #{message}"
    end
  end
end
