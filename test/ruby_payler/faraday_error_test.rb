require 'test_helper'
require_relative 'payler_flow_test'

# Test case when request via Faraday raises error
class FaradayErrorTest < PaylerFlowTest
  def test_faraday_request_error
    Faraday::Connection.any_instance.stubs(:post).raises(Faraday::Error)
    expected_code = 'NetworkError'
    expected_message = '#<Faraday::Error: Faraday::Error>'
    expected_to_s =
      'NetworkError occured while performing request to Payler: #<Faraday::Error: Faraday::Error>'

    begin
      start_session(SESSION_TYPES[:one_step])
    rescue ::RubyPayler::NetworkError => error
      assert_equal expected_message, error.message
      assert_equal expected_to_s, error.to_s
      assert_equal expected_code, error.code
    end
  end
end
