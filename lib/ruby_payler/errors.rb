module RubyPayler
  class Error < RuntimeError
  end

  # Faraday errors
  class FailedRequest < Error
  end

  # Response.body contains error
  class ResponseWithError < Error
    attr_reader :error

    def initialize(error)
      @error = error
    end

    def code
      error.code
    end

    def message
      error.message
    end

    def to_s
      "#{self.class}-#{code}-#{message}"
    end
  end
end
