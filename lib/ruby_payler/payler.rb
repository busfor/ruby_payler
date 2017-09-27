require 'faraday'
require 'faraday_middleware'

module RubyPayler
  # Wrapper for payler gate api
  class Payler
    attr_reader :host, :key, :password, :debug

    def initialize(host:, key:, password:, debug: false)
      @host = host
      @key = key
      @password = password
      @debug = debug
    end

    def start_session(
      type:,
      order_id:,
      cents:,
      **other_session_params
    )
      call_payler_api('gapi/StartSession',
        type: type,
        order_id: order_id,
        amount: cents,
        **other_session_params,
      )
    end

    def find_session(order_id)
      call_payler_api('gapi/FindSession', order_id: order_id)
    end

    def pay_page_url(session_id)
      "#{connection.url_prefix}gapi/Pay?key=#{key}&session_id=#{session_id}"
    end

    def get_status(order_id)
      call_payler_api('gapi/GetStatus', order_id: order_id)
    end

    def get_advanced_status(order_id)
      call_payler_api('gapi/GetAdvancedStatus', order_id: order_id)
    end

    def charge(order_id, amount)
      call_payler_api('gapi/Charge',
        password: password,
        order_id: order_id,
        amount: amount,
      )
    end

    def retrieve(order_id, amount)
      call_payler_api('gapi/Retrieve',
        password: password,
        order_id: order_id,
        amount: amount,
      )
    end

    def refund(order_id, amount)
      call_payler_api('gapi/Refund',
        password: password,
        order_id: order_id,
        amount: amount,
      )
    end

    def get_template(recurrent_template_id)
      call_payler_api('gapi/GetTemplate',
        recurrent_template_id: recurrent_template_id,
      )
    end

    def activate_template(recurrent_template_id, active)
      call_payler_api('gapi/ActivateTemplate',
        recurrent_template_id: recurrent_template_id,
        active: active,
      )
    end

    def repeat_pay(order_id:, amount:, recurrent_template_id:)
      call_payler_api('gapi/RepeatPay',
        order_id: order_id,
        amount: amount,
        recurrent_template_id: recurrent_template_id,
      )
    end

    private

    def connection
      @connection ||= Faraday.new(
        url: "https://#{host}.payler.com",
        params: { key: @key },
      ) do |f|
        f.request :url_encoded # form-encode POST params

        f.params

        f.response :mashify          # 3. mashify parsed JSON
        f.response :json             # 2. parse JSON
        f.response :logger if debug  # 1. log requests to STDOUT

        f.adapter Faraday.default_adapter # make requests with Net::HTTP
      end
    end

    def call_payler_api(endpoint, params)
      remove_nils_from_params!(params)
      params[:key] = key

      begin
        response = connection.post(endpoint, params)
      rescue Faraday::Error => faraday_error
        raise RubyPayler::NetworkError, faraday_error
      end

      # TODO: так не заходит, надо передумать
      unless [200, 400, 403, 404, 500].include? response.status
        raise RubyPayler::UnexpectedHttpResponseStatusError, response.status
      end

      response_body = response.body
      raise RubyPayler::ResponseError, response_body.error if response_body.error

      response_body
    end

    def remove_nils_from_params!(params)
      params.delete_if { |_key, value| value.nil? }
    end
  end # class Payler
end # module RubyPayler
