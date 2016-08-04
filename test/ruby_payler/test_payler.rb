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
      type: 'TwoStep',
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
        type: 'TwoStep',
      )
      @order_id = "busfor_test_#{DateTime.now.strftime("%Y-%m-%d-%N")}"
    end

    def test_start_session
      session_id = @payler.start_session(@order_id).session_id

      assert_equal String, session_id.class
    end

    def test_start_session_get_status_error_flow
      session_id = @payler.start_session(@order_id).session_id
      status = @payler.get_status(@order_id)
      error = status.error

      assert error
      assert_equal 603, error.code
      assert_equal "Пользователь не предпринимал попыток оплаты.", error.message
    end

    def test_start_session_pay_get_status_authorized_flow
      session_id = @payler.start_session(@order_id).session_id
      pay_url = @payler.pay_page_url(session_id)

      pay(pay_url)

      status = @payler.get_status(@order_id)

      assert_equal 'Authorized', status.status
    end

    def test_start_session_pay_charge_get_status_flow
      session_id = @payler.start_session(@order_id).session_id
      pay_url = @payler.pay_page_url(session_id)

      pay(pay_url)

      result = @payler.charge(@order_id, 177)
      assert_equal 177, result.amount
      assert_equal @order_id, result.order_id

      status = @payler.get_status(@order_id)
      assert_equal 'Charged', status.status
      assert_equal @order_id, status.order_id
      assert_equal 177, status.amount
    end

    def test_retrieve

    end
  end
end
