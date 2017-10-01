require 'test_helper'
require_relative 'payler_flow_test'

# Test passing user data from session init to advanced status
class AdvancedStatusFlowTest < PaylerFlowTest
  def test_pass_user_data_to_advanced_status
    VCR.use_cassette('pass_user_data_to_advanced_status') do
      user_data = 'user_data'
      @session_id = @payler.start_session(
        order_id: @order_id,
        type: SESSION_TYPES[:two_step],
        cents: @order_amount,
        currency: @order_currency,
        lang: @lang,
        userdata: user_data,
      ).session_id

      pay

      advanced_status = @payler.get_advanced_status(@order_id)
      assert_equal user_data, advanced_status.userdata
    end
  end
end
