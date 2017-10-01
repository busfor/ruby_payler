require 'ruby_payler/connection'

module RubyPayler
  # Wrapper for payler gate api
  class Payler
    attr_reader :host, :key, :password, :debug, :payler_url

    def initialize(host:, key:, password:, debug: false)
      @host = host
      @key = key
      @password = password
      @debug = debug

      @payler_url = "https://#{host}.payler.com/gapi/"
    end

    def start_session(
      type:,
      order_id:,
      cents:,
      **other_session_params
    )
      call_payler_api('StartSession',
        type: type,
        order_id: order_id,
        amount: cents,
        **other_session_params,
      )
    end

    def find_session(order_id)
      call_payler_api('FindSession', order_id: order_id)
    end

    def pay_page_url(session_id)
      "#{payler_url}Pay?key=#{key}&session_id=#{session_id}"
    end

    def get_status(order_id)
      call_payler_api('GetStatus', order_id: order_id)
    end

    def get_advanced_status(order_id)
      call_payler_api('GetAdvancedStatus', order_id: order_id)
    end

    def charge(order_id, amount)
      call_payler_api('Charge',
        password: password,
        order_id: order_id,
        amount: amount,
      )
    end

    def retrieve(order_id, amount)
      call_payler_api('Retrieve',
        password: password,
        order_id: order_id,
        amount: amount,
      )
    end

    def refund(order_id, amount)
      call_payler_api('Refund',
        password: password,
        order_id: order_id,
        amount: amount,
      )
    end

    def get_template(recurrent_template_id)
      call_payler_api('GetTemplate',
        recurrent_template_id: recurrent_template_id,
      )
    end

    def activate_template(recurrent_template_id, active)
      call_payler_api('ActivateTemplate',
        recurrent_template_id: recurrent_template_id,
        active: active,
      )
    end

    def repeat_pay(order_id:, amount:, recurrent_template_id:)
      call_payler_api('RepeatPay',
        order_id: order_id,
        amount: amount,
        recurrent_template_id: recurrent_template_id,
      )
    end

    private

    def connection
      @connection ||= Connection.new(url: payler_url, key: key, debug: debug)
    end

    def call_payler_api(endpoint, params)
      remove_nils_from_params!(params)
      params[:key] = key

      begin
        response = connection.post(endpoint, params)
      rescue Faraday::Error => faraday_error
        raise RubyPayler::NetworkError, faraday_error
      end

      response_body = response.body
      if (response_body.class != Hashie::Mash) ||
         (response.status != 200 && !response_body.include?(:error))
        raise RubyPayler::UnexpectedResponseError, response
      end

      raise RubyPayler::ResponseError, response if response_body.error

      response_body
    end

    def remove_nils_from_params!(params)
      params.delete_if { |_key, value| value.nil? }
    end
  end # class Payler
end # module RubyPayler
