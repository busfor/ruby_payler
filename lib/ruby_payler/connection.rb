require 'faraday'
require 'faraday_middleware'

module RubyPayler
  # Network connection to Payler
  class Connection
    def initialize(url:, key:, debug: false)
      @driver = Faraday.new(url: url, params: { key: key }) do |f|
        f.request :url_encoded # form-encode POST params

        f.response :mashify          # 3. mashify parsed JSON
        f.response :json             # 2. parse JSON
        f.response :logger if debug  # 1. log requests to STDOUT

        f.adapter Faraday.default_adapter # make requests with Net::HTTP
      end
    end

    def post(endpoint, params)
      @driver.post(endpoint, params)
    end
  end
end
