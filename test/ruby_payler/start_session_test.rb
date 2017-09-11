require 'test_helper'
require_relative 'payler_flow_test'

# Test start_session method works
class StartSessionTest < PaylerFlowTest
  def test_start_session
    session_id = start_session(SESSION_TYPES[:two_step])

    assert_equal String, session_id.class
  end
end
