require 'test_helper'
require_relative 'payler_flow_test'

# Test main flows for two-step payments
class TwoStepPaymentFlowsTest < PaylerFlowTest
  def test_start_session_pay_get_status_authorized_flow
    VCR.use_cassette('start_session_request_status') do
      start_session(SESSION_TYPES[:two_step])
      pay
      request_status

      assert_equal 'Authorized', @status.status
    end
  end

  def test_start_session_pay_charge_get_status_flow
    VCR.use_cassette('start_session_charge_get_status') do
      start_session(SESSION_TYPES[:two_step])
      pay

      result = @payler.charge(@order_id, @order_amount)
      assert_equal @order_amount, result.amount

      request_status

      assert_equal 'Charged', @status.status
      assert_equal @order_amount, @status.amount
    end
  end

  def test_start_session_pay_retreive_get_status_flow
    VCR.use_cassette('start_session_retreive_get_status') do
      start_session(SESSION_TYPES[:two_step])
      pay

      result = @payler.retrieve(@order_id, @order_amount)
      assert_equal 0, result.new_amount

      request_status

      assert_equal 'Reversed', @status.status
      assert_equal @order_amount, @status.amount
    end
  end

  def test_refund_in_two_step_flow
    VCR.use_cassette('start_session_charge_refund') do
      start_session(SESSION_TYPES[:two_step])
      pay
      @payler.charge(@order_id, @order_amount)

      result = @payler.refund(@order_id, @order_amount)

      assert_equal 0, result.amount

      request_status

      assert_equal 'Refunded', @status.status
      assert_equal @order_amount, @status.amount
    end
  end
end
