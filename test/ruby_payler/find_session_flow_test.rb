require 'test_helper'
require_relative 'payler_flow_test'

# Test find_session method use-case
class FindSessionFlowTest < PaylerFlowTest
  def test_pass_data_from_start_session_to_find_session
    session_id = @payler.start_session(
      type: SESSION_TYPES[:one_step],
      order_id: @order_id,
      cents: 777,
      product: 'Test product',
      total: 7.77,
      template: 'Test template',
      lang: LANGUAGES[:en],
      userdata: 'Test userdata',
      recurrent: 'true',
      pay_page_param_one: 'one',
      pay_page_param_two: 'two',
    ).session_id

    session_info = @payler.find_session(@order_id)

    assert_equal session_id, session_info.id
    assert DateTime.parse(session_info.created)
    assert DateTime.parse(session_info.valid_through)
    assert_equal SESSION_TYPES[:one_step], session_info.type
    assert_equal @order_id, session_info.order_id
    assert_equal 777, session_info.amount
    assert_equal 'Test product', session_info.product
    assert_equal 'RUB', session_info.currency
    assert_equal 'Test userdata', session_info.userdata
    assert_equal 'EN', session_info.lang
    assert_equal true, session_info.recurrent
    assert_equal 'one', session_info.pay_page_params.pay_page_param_one
    assert_equal 'two', session_info.pay_page_params.pay_page_param_two
  end
end
