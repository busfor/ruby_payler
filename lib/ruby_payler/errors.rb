module RubyPayler
  class Error < RuntimeError
    def code
      raise 'RubyPayler::Error should implement #code method'
    end

    def message
      raise 'RubyPayler::Error should implement #message method'
    end
  end

  # Faraday errors
  class FailedRequest < Error
    def code
      'FailedRequest'
    end

    def message
      self.to_s
    end
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
