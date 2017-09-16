require 'test_helper'
require_relative 'payler_flow_test'

# Test payler flows leading to errors
class ErrorFlowsTest < PaylerFlowTest
  def test_start_session_get_status_error_flow
    start_session(SESSION_TYPES[:two_step])

    begin
      request_status
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
      request_status
    rescue ::RubyPayler::ResponseWithError => error
      assert_equal 603, error.code
      assert_equal 'User has not attempted to pay.', error.message
    end
    assert error
  end
end
