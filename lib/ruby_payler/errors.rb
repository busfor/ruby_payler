module RubyPayler
  # Base error class for all RubyPayler errors
  # Every RubyPayler Error Class must have code, message and to_s methods!
  class Error < RuntimeError
  end

  # Response.body contains error
  class ResponseError < Error
    attr_reader :error

    def initialize(error)
      @error = error
    end

    # Payler error code
    def code
      error.code
    end

    # Payler error description
    def message
      error.message
    end

    def to_s
      "Payler responded with error: #{message}, code #{code}"
    end
  end

  # Unexpected http response status
  class UnexpectedHttpResponseStatusError < Error
    attr_reader :code

    def initialize(code)
      @code = code
    end

    def message
      "Payler responded with unexpected HTTP-status: #{code}"
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
