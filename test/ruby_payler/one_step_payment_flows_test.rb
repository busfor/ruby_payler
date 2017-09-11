require 'test_helper'
require_relative 'payler_flow_test'

# Test main flows for one-step payment
class OneStepPaymentFlowsTest < PaylerFlowTest
  def test_pay_in_one_step_get_status_flow
    start_session(SESSION_TYPES[:one_step])
    pay

    request_status

    assert_equal 'Charged', @status.status
    assert_equal @order_amount, @status.amount
  end

  def test_refund_in_one_step_flow
    start_session(SESSION_TYPES[:one_step])
    pay

    result = @payler.refund(@order_id, @order_amount)

    assert_equal 0, result.amount

    request_status

    assert_equal 'Refunded', @status.status
    assert_equal @order_amount, @status.amount
  end
end
