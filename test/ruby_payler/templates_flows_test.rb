require 'test_helper'
require_relative 'payler_flow_test'

# Test case when request via Faraday raises error
class TemplatesFlowsTest < PaylerFlowTest
  def test_templates
    @lang = LANGUAGES[:en]
    @session_id = @payler.start_session(
      type: SESSION_TYPES[:two_step],
      order_id: @order_id,
      cents: @order_amount,
      currency: @order_currency,
      lang: LANGUAGES[:en],
      recurrent: true,
    ).session_id

    pay

    status = @payler.get_status(@order_id)
    recurrent_template_id = status.recurrent_template_id

    assert recurrent_template_id

    template_info = @payler.get_template(recurrent_template_id)
    assert_equal false, template_info.active
    assert template_info.recurrent_template_id
    assert DateTime.parse(template_info.created)
    assert template_info.card_holder
    assert template_info.card_number
    assert template_info.expiry

    expected_error_message =
      'Активация шаблона рекуррентных платежей требует подтверждения со стороны банка.'
    # Now try to activate template
    begin
      @payler.activate_template(recurrent_template_id, true)
    rescue ::RubyPayler::ResponseWithError => error
      assert_equal 104, error.code
      assert_equal expected_error_message, error.message
    end
    assert error

    # Try to repeat_pay
    begin
      @payler.repeat_pay(
        order_id: @order_id + '-repeat',
        amount: @order_amount,
        recurrent_template_id: recurrent_template_id,
      )
    rescue ::RubyPayler::ResponseWithError => error
      assert_equal 27, error.code
      assert_equal 'Шаблон рекуррентных платежей неактивен.', error.message
    end
    assert error
  end
end
