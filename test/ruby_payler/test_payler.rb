require 'test_helper'

class RubyPaylerTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::RubyPayler::VERSION
  end

  def test_pay_page_url
    key = '123'
    session_id = '321'
    payler = RubyPayler::Payler.new(
      host: 'host',
      key: key,
      password: 'password',
    )
    correct_url =
      "https://host.payler.com/gapi/Pay?key=#{key}&session_id=#{session_id}"

    assert_equal correct_url, payler.pay_page_url(session_id)
  end

  class TestPaylerFlows < CapybaraTestCase
    def setup
      shop = CONFIG.shop
      @payler = RubyPayler::Payler.new(
        host: shop.host,
        key: shop.key_,
        password: shop.password,
      )
      @order_id = "busfor_test_#{DateTime.now.strftime("%Y-%m-%d-%N")}"
      @order_amount = 111
      @order_currency = 'RUB'
      @lang = 'ru'
      @session_id = "Filled in start_session"
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

    def test_start_session
      session_id = start_session('TwoStep')

      assert_equal String, session_id.class
    end

    def test_start_session_get_status_error_flow
      start_session('TwoStep')
      status = @payler.get_status(@order_id)

      error = status.error

      assert error
      assert_equal 603, error.code
      assert_equal "Пользователь не предпринимал попыток оплаты.", error.message
    end

    def test_start_session_pay_get_status_authorized_flow
      start_session('TwoStep')
      pay

      status = @payler.get_status(@order_id)

      assert_equal 'Authorized', status.status
    end

    def test_start_session_pay_charge_get_status_flow
      start_session('TwoStep')
      pay

      result = @payler.charge(@order_id, @order_amount)
      assert_equal @order_amount, result.amount
      assert_equal @order_id, result.order_id

      status = @payler.get_status(@order_id)

      assert_equal 'Charged', status.status
      assert_equal @order_id, status.order_id
      assert_equal @order_amount, status.amount
    end

    def test_start_session_pay_retreive_get_status_flow
      start_session('TwoStep')
      pay

      result = @payler.retrieve(@order_id, @order_amount)
      assert_equal @order_id, result.order_id
      assert_equal 0, result.new_amount

      status = @payler.get_status(@order_id)

      assert_equal 'Reversed', status.status
      assert_equal @order_amount, status.amount
    end

    def test_pay_in_one_step_get_status_flow
      start_session('OneStep')
      pay

      status = @payler.get_status(@order_id)

      assert_equal 'Charged', status.status
      assert_equal @order_amount, status.amount
    end
  end
end
