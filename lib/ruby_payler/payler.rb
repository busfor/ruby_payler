require 'faraday'
require 'faraday_middleware'

module RubyPayler
  class Payler
    attr_reader :host, :key, :password, :connection

    def initialize(host:, key:, password:)
      @host = host
      @key = key
      @password = password

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

    def remove_nils_from_params!(params)
      params.delete_if { |k, v| v.nil? }
    end

    def call_payler_api(endpoint, params)
      remove_nils_from_params!(params)

      begin
        response = connection.post(endpoint, params)
      rescue Faraday::Error => e
        raise RequestError, e.message
      end

      result = response.body
      if result.error
        raise ResponseWithError, result.error
      end
      result
    end

    def start_session(
      order_id:,
      type:,
      cents:,
      currency:,
      lang:,
      product: nil,
      userdata: nil
    )
      params =
      call_payler_api('gapi/StartSession', {
        key: key,
        type: type,
        order_id: order_id,
        currency: currency,
        amount: cents,
        lang: lang,
        product: product,
        userdata: userdata,
      })
    end

    def pay_page_url(session_id)
      "#{connection.url_prefix.to_s}gapi/Pay?key=#{key}&session_id=#{session_id}"
    end

    def get_status(order_id)
      call_payler_api('gapi/GetStatus', {
        key: key,
        order_id: order_id,
      })
    end

    def get_advanced_status(order_id)
      call_payler_api('gapi/GetAdvancedStatus', {
        key: key,
        order_id: order_id,
      })
    end

    def charge(order_id, amount)
      call_payler_api('gapi/Charge', {
        key: key,
        password: password,
        order_id: order_id,
        amount: amount,
      })
    end

    def retrieve(order_id, amount)
      call_payler_api('gapi/Retrieve', {
        key: key,
        password: password,
        order_id: order_id,
        amount: amount,
      })
    end

    def refund(order_id, amount)
      call_payler_api('gapi/Refund', {
        key: key,
        password: password,
        order_id: order_id,
        amount: amount,
      })
    end
  end
end
