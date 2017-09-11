require 'test_helper'
require_relative 'payler_flow_test'

# Test case when request via Faraday raises error
class FaradayErrorTest < PaylerFlowTest
  def test_faraday_request_error
    Faraday::Connection.any_instance.stubs(:post).raises(Faraday::Error)

    assert_raises(::RubyPayler::FailedRequest) do
      start_session(SESSION_TYPES[:one_step])
    end
  end
end
