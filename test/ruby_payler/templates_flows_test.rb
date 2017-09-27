require 'test_helper'
require_relative 'payler_flow_test'

# Test payler flows related to recurrent templates
class TemplatesFlowsTest < PaylerFlowTest
  # returns created recurrent_template_id
  def create_payment_with_recurrent_template
    @session_id = @payler.start_session(
      type: SESSION_TYPES[:two_step],
      order_id: @order_id,
      cents: @order_amount,
      recurrent: true,
    ).session_id

    pay

    @payler.get_status(@order_id).recurrent_template_id
  end

  def test_recurrent_template_creation
    VCR.use_cassette('create_payment_with_recurrent_template') do
      recurrent_template_id = create_payment_with_recurrent_template

      assert recurrent_template_id
    end
  end

  def test_recurrent_template_info
    VCR.use_cassette('get_recurrent_template_info') do
      recurrent_template_id = create_payment_with_recurrent_template
      template_info = @payler.get_template(recurrent_template_id)

      assert_equal false, template_info.active
      assert template_info.recurrent_template_id
      assert DateTime.parse(template_info.created)
      assert template_info.card_holder
      assert template_info.card_number
      assert template_info.expiry
    end
  end

  def test_recurrent_template_activation_failure
    expected_error_message =
      'Активация шаблона рекуррентных платежей требует подтверждения со стороны банка.'

    VCR.use_cassette('recurrent_template_activation_failure') do
      recurrent_template_id = create_payment_with_recurrent_template
      begin
        @payler.activate_template(recurrent_template_id, true)
      rescue ::RubyPayler::ResponseError => error
        assert_equal 104, error.code
        assert_equal expected_error_message, error.message
      end
      assert error
    end
  end

  def test_recurrent_template_repeat_pay_fail
    expected_error_message = 'Шаблон рекуррентных платежей неактивен.'
    expected_error_to_s =
      'Payler responded with error: Шаблон рекуррентных платежей неактивен., code 27'

    VCR.use_cassette('recurrent_template_repeat_pay_fail') do
      recurrent_template_id = create_payment_with_recurrent_template
      begin
        @payler.repeat_pay(
          order_id: @order_id + '-repeat',
          amount: @order_amount,
          recurrent_template_id: recurrent_template_id,
        )
      rescue ::RubyPayler::ResponseError => error
        assert_equal 27, error.code
        assert_equal expected_error_message, error.message
        assert_equal expected_error_to_s, error.to_s
      end
      assert error
    end
  end
end
