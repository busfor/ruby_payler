require 'faraday'
require 'faraday_middleware'

module RubyPayler
  class Payler
    attr_reader :host, :key, :password

    def initialize(host:, key:, password:, debug: false)
      @host = host
      @key = key
      @password = password

      @connection = Faraday.new(
        url: "https://#{host}.payler.com",
        params: { key: @key },
      ) do |f|
        f.request :url_encoded # form-encode POST params

        f.params

        f.response :mashify          # 3. mashify parsed JSON
        f.response :json             # 2. parse JSON
        f.response :logger if debug  # 1. log requests to STDOUT

        f.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end

    # pay_page_param_* можно передать любые параметры, чтобы потом отобразить
    def start_session(
      type:,
      order_id:,
      cents:,
      currency: nil,
      product: nil,
      total: nil,
      template: nil,
      lang: nil,
      userdata: nil,
      recurrent: nil,
      **pay_page_params
    )
      pay_page_params.select! do |key, _value|
        key.to_s.start_with?('pay_page_param_')
      end

      call_payler_api('gapi/StartSession', {
        type: type,
        order_id: order_id,
        amount: cents,
        currency: currency,
        product: product,
        total: total,
        template: template,
        lang: lang,
        userdata: userdata,
        recurrent: recurrent,
        **pay_page_params,
      })
    end

    def find_session(order_id)
      call_payler_api('gapi/FindSession', {
        order_id: order_id,
      })
    end

    def pay_page_url(session_id)
      "#{connection.url_prefix.to_s}gapi/Pay?key=#{key}&session_id=#{session_id}"
    end

    def get_status(order_id)
      call_payler_api('gapi/GetStatus', {
        order_id: order_id,
      })
    end

    def get_advanced_status(order_id)
      call_payler_api('gapi/GetAdvancedStatus', {
        order_id: order_id,
      })
    end

    def charge(order_id, amount)
      call_payler_api('gapi/Charge', {
        password: password,
        order_id: order_id,
        amount: amount,
      })
    end

    def retrieve(order_id, amount)
      call_payler_api('gapi/Retrieve', {
        password: password,
        order_id: order_id,
        amount: amount,
      })
    end

    def refund(order_id, amount)
      call_payler_api('gapi/Refund', {
        password: password,
        order_id: order_id,
        amount: amount,
      })
    end

    def get_template(recurrent_template_id)
      call_payler_api('gapi/GetTemplate', {
        recurrent_template_id: recurrent_template_id,
      })
    end

    def activate_template(recurrent_template_id, active)
      call_payler_api('gapi/ActivateTemplate', {
        recurrent_template_id: recurrent_template_id,
        active: active,
      })
    end

    def repeat_pay(order_id:, amount:, recurrent_template_id:)
      call_payler_api('gapi/RepeatPay', {
        order_id: order_id,
        amount: amount,
        recurrent_template_id: recurrent_template_id,
      })
    end

    private

    def connection
      @connection
    end


    def call_payler_api(endpoint, params)
      remove_nils_from_params!(params)
      params[:key] = key

      begin
        response = connection.post(endpoint, params)
      rescue Faraday::Error => e
        raise FailedRequest, e.message
      end

      result = response.body
      if result.error
        raise ResponseWithError, result.error
      end
      result
    end

    def remove_nils_from_params!(params)
      params.delete_if { |k, v| v.nil? }
    end
  end # class Payler
end # module RubyPayler
