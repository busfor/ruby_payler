module RubyPayler
  class Error < RuntimeError
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
