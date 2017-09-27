require 'test_helper'
require_relative 'payler_flow_test'

# Test payment page that payler renders for payment session
class OneStepPaymentFlowsTest < PaylerFlowTest
  def test_payment_page_contains_product_name_if_passed
    product_name = 'Тестовый продукт'
    VCR.use_cassette('payment_page_with_product_name') do
      @session_id = @payler.start_session(
        order_id: @order_id,
        type: SESSION_TYPES[:two_step],
        cents: @order_amount,
        currency: @order_currency,
        lang: @lang,
        product: product_name,
      ).session_id
      page.visit(@payler.pay_page_url(@session_id))
      assert page.has_content?(product_name)
    end
  end
end
