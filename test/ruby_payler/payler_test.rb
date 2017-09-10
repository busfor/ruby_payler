require 'test_helper'

class RubyPaylerTest < Minitest::Test
  class TestPaylerFlows < CapybaraTestCase
    include RubyPayler::Constants
    def setup
      shop = CONFIG.shop
      @payler = RubyPayler::Payler.new(
        host: shop.host,
        key: shop.key_,
        password: shop.password,
      )
      @order_id = "busfor_test_#{DateTime.now.strftime('%Y-%m-%d-%N')}"
      @order_amount = 111
      @order_currency = CURRENCIES[:rub]
      @lang = LANGUAGES[:ru]
      @session_id = 'Filled in start_session'
      @status = 'Filled in get_status'
    end

    def start_session(type)
      @session_id = @payler.start_session(
        order_id: @order_id,
        type: type,
        cents: @order_amount,
        currency: @order_currency,
        lang: @lang,
      ).session_id
    end

    def pay
      perform_payment(@payler.pay_page_url(@session_id))
    end

    def get_status
      @status = @payler.get_status(@order_id)
    end

    def test_start_session
      session_id = start_session(SESSION_TYPES[:two_step])

      assert_equal String, session_id.class
    end

    def test_templates
      @lang = LANGUAGES[:en]
      @session_id = @payler.start_session(
        type: SESSION_TYPES[:two_step],
        order_id: @order_id,
        cents: @order_amount,
        currency: @order_currency,
        lang: LANGUAGES[:en],
        recurrent: true,
      ).session_id

      pay

      status = @payler.get_status(@order_id)
      recurrent_template_id = status.recurrent_template_id

      assert recurrent_template_id

      template_info = @payler.get_template(recurrent_template_id)
      assert_equal false, template_info.active
      assert template_info.recurrent_template_id
      assert DateTime.parse(template_info.created)
      assert template_info.card_holder
      assert template_info.card_number
      assert template_info.expiry

      expected_error_message =
        'Активация шаблона рекуррентных платежей требует подтверждения со стороны банка.'
      # Now try to activate template
      begin
        @payler.activate_template(recurrent_template_id, true)
      rescue ::RubyPayler::ResponseWithError => error
        assert_equal 104, error.code
        assert_equal expected_error_message, error.message
      end
      assert error

      # Try to repeat_pay
      begin
        @payler.repeat_pay(
          order_id: @order_id + '-repeat',
          amount: @order_amount,
          recurrent_template_id: recurrent_template_id,
        )
      rescue ::RubyPayler::ResponseWithError => error
        assert_equal 27, error.code
        assert_equal 'Шаблон рекуррентных платежей неактивен.', error.message
      end
      assert error
    end

    def test_pass_data_from_start_session_to_find_session
      session_id = @payler.start_session(
        type: SESSION_TYPES[:one_step],
        order_id: @order_id,
        cents: 777,
        product: 'Test product',
        total: 7.77,
        template: 'Test template',
        lang: LANGUAGES[:en],
        userdata: 'Test userdata',
        recurrent: 'true',
        pay_page_param_one: 'one',
        pay_page_param_two: 'two',
      ).session_id

      session_info = @payler.find_session(@order_id)

      assert_equal session_id, session_info.id
      assert DateTime.parse(session_info.created)
      assert DateTime.parse(session_info.valid_through)
      assert_equal SESSION_TYPES[:one_step], session_info.type
      assert_equal @order_id, session_info.order_id
      assert_equal 777, session_info.amount
      assert_equal 'Test product', session_info.product
      assert_equal 'RUB', session_info.currency
      assert_equal 'Test userdata', session_info.userdata
      assert_equal 'EN', session_info.lang
      assert_equal true, session_info.recurrent
      assert_equal 'one', session_info.pay_page_params.pay_page_param_one
      assert_equal 'two', session_info.pay_page_params.pay_page_param_two
    end

    def test_pass_user_data_through_start_session_and_advanced_status
      user_data = 'user_data'
      @session_id = @payler.start_session(
        order_id: @order_id,
        type: SESSION_TYPES[:two_step],
        cents: @order_amount,
        currency: @order_currency,
        lang: @lang,
        userdata: user_data,
      ).session_id
      pay # Returns error if user didn't try to pay

      advanced_status = @payler.get_advanced_status(@order_id)

      assert_equal user_data, advanced_status.userdata
    end

    def test_pay_page_contains_product_name
      product_name = 'Тестовый продукт'
      @session_id = @payler.start_session(
        order_id: @order_id,
        type: SESSION_TYPES[:two_step],
        cents: @order_amount,
        currency: @order_currency,
        lang: @lang,
        product: product_name,
      ).session_id
      page.visit(@payler.pay_page_url(@session_id))
      assert page.has_content?(product_name)
    end

    def test_pay_page_contains_product_id_if_no_name_passed
      @session_id = @payler.start_session(
        order_id: @order_id,
        type: SESSION_TYPES[:two_step],
        cents: @order_amount,
        currency: @order_currency,
        lang: @lang,
      ).session_id
      page.visit(@payler.pay_page_url(@session_id))
      assert page.has_content?(@order_id)
    end

    def test_start_session_pay_get_status_authorized_flow
      start_session(SESSION_TYPES[:two_step])
      pay
      get_status

      assert_equal 'Authorized', @status.status
    end

    def test_start_session_pay_charge_get_status_flow
      start_session(SESSION_TYPES[:two_step])
      pay

      result = @payler.charge(@order_id, @order_amount)
      assert_equal @order_amount, result.amount
      assert_equal @order_id, result.order_id

      get_status

      assert_equal 'Charged', @status.status
      assert_equal @order_id, @status.order_id
      assert_equal @order_amount, @status.amount
    end

    def test_start_session_pay_retreive_get_status_flow
      start_session(SESSION_TYPES[:two_step])
      pay

      result = @payler.retrieve(@order_id, @order_amount)
      assert_equal @order_id, result.order_id
      assert_equal 0, result.new_amount

      get_status

      assert_equal 'Reversed', @status.status
      assert_equal @order_amount, @status.amount
    end

    def test_refund_in_two_step_flow
      start_session(SESSION_TYPES[:two_step])
      pay
      @payler.charge(@order_id, @order_amount)

      result = @payler.refund(@order_id, @order_amount)

      assert_equal 0, result.amount

      get_status

      assert_equal 'Refunded', @status.status
      assert_equal @order_amount, @status.amount
    end

    def test_pay_in_one_step_get_status_flow
      start_session(SESSION_TYPES[:one_step])
      pay

      get_status

      assert_equal 'Charged', @status.status
      assert_equal @order_amount, @status.amount
    end

    def test_refund_in_one_step_flow
      start_session(SESSION_TYPES[:one_step])
      pay

      result = @payler.refund(@order_id, @order_amount)

      assert_equal 0, result.amount

      get_status

      assert_equal 'Refunded', @status.status
      assert_equal @order_amount, @status.amount
    end

    def test_start_session_get_status_error_flow
      start_session(SESSION_TYPES[:two_step])

      begin
        get_status
      rescue ::RubyPayler::ResponseWithError => error
        assert_equal 603, error.code
        assert_equal 'Пользователь не предпринимал попыток оплаты.', error.message
      end
      assert error
    end

    def test_try_charge_more_than_authorized_error_flow
      start_session(SESSION_TYPES[:two_step])
      pay

      begin
        @payler.charge(@order_id, @order_amount + 1)
      rescue ::RubyPayler::ResponseWithError => error
        assert_equal 1, error.code
        assert_equal 'Неверно указана сумма транзакции.', error.message
      end
      assert error
    end

    def test_error_in_english_session
      @lang = LANGUAGES[:en]
      start_session(SESSION_TYPES[:two_step])

      begin
        get_status
      rescue ::RubyPayler::ResponseWithError => error
        assert_equal 603, error.code
        assert_equal 'User has not attempted to pay.', error.message
      end
      assert error
    end

    def test_faraday_request_error
      Faraday::Connection.any_instance.stubs(:post).raises(Faraday::Error)

      assert_raises(RubyPayler::FailedRequest) do
        start_session(SESSION_TYPES[:one_step])
      end
    end
  end
end
