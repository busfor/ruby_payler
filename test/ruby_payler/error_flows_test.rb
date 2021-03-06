require 'test_helper'
require_relative 'payler_flow_test'

# Test payler flows leading to errors
class ErrorFlowsTest < PaylerFlowTest
  def test_start_session_get_status_error_flow
    @lang = LANGUAGES[:en]
    VCR.use_cassette('user_han_not_attempted_to_pay_ru') do
      start_session(SESSION_TYPES[:two_step])

      begin
        request_status
      rescue ::RubyPayler::ResponseError => error
        assert_equal 603, error.code
        assert_equal 'User has not attempted to pay.', error.message
      end
      assert error
    end
  end

  def test_try_charge_more_than_authorized_error_flow
    @lang = LANGUAGES[:en]
    VCR.use_cassette('try_to_charge_more_than_authorized') do
      start_session(SESSION_TYPES[:two_step])
      pay

      begin
        @payler.charge(@order_id, @order_amount + 1)
      rescue ::RubyPayler::ResponseError => error
        assert_equal 1, error.code
        assert_equal 'Invalid amount of the transaction.', error.message
        assert_equal 'Payler responded with error: Invalid amount of the transaction., code 1', error.to_s
      end
      assert error
    end
  end

  def test_payler_unavailable_code_503
    expected_error_message = 'Unexpected response: code - 503, body - '

    failing_connection = Faraday.new do |f|
      f.request :url_encoded # form-encode POST params

      f.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post('StartSession') { |_env| [503, {}, ''] }
      end
    end
    ::RubyPayler::Payler.any_instance.stubs(:connection).returns failing_connection

    VCR.use_cassette('payler_unexpected_response') do
      begin
        start_session(SESSION_TYPES[:two_step])
      rescue ::RubyPayler::UnexpectedResponseError => error
        assert_equal 503, error.code
        assert_equal expected_error_message, error.message
        assert_equal expected_error_message, error.to_s
      end
      assert error
    end
  end
end
