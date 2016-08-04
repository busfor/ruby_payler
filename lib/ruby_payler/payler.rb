require 'faraday'
require 'faraday_middleware'
require 'pry-byebug'

module RubyPayler
  class Payler
    attr_reader :host, :key, :password, :type, :connection

    def initialize(host:, key:, password:, type:)
      @host = host
      @key = key
      @password = password
      @type = type

      @connection = Faraday.new(
        url: "https://#{host}.payler.com",
        params: { key: @key },
      ) do |f|
        f.request  :url_encoded # form-encode POST params

        f.params

        f.response :mashify  # 3. mashify parsed JSON
        f.response :json     # 2. parse JSON
        #f.response :logger  # 1. log requests to STDOUT

        f.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end

    def start_session(order_id)
      connection.post('gapi/StartSession', {
        key: key,
        type: type,
        order_id: order_id,
        currency: 'RUB',
        amount: 177,
      }).body
    end

    def pay_page_url(session_id)
      "#{connection.url_prefix.to_s}gapi/Pay?key=#{key}&session_id=#{session_id}"
    end

    def get_status(order_id)
      connection.post('gapi/GetStatus', {
        key: key,
        order_id: order_id,
      }).body
    end

    def charge(order_id, amount)
      connection.post('gapi/Charge', {
        key: key,
        password: password,
        order_id: order_id,
        amount: amount,
      }).body
    end

    def retrieve(order_id, amount)
      connection.post('gapi/Retrieve', {
        key: key,
        password: password,
        order_id: order_id,
        amount: amount,
      }).body
    end
  end
end
