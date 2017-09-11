require 'test_helper'

# Base class to test flows of payler API commands
class PaylerFlowTest < CapybaraTestCase
  include RubyPayler::Constants
  def setup
    shop = CONFIG.shop
    @payler = RubyPayler::Payler.new(
      host: shop.host,
      key: shop.key_,
      password: shop.password,
    )
    @order_id = "busfor_test_#{DateTime.now.strftime('%Y-%m-%d-%N')}"
    @order_amount = 111
    @order_currency = CURRENCIES[:rub]
    @lang = LANGUAGES[:ru]
    @session_id = 'Filled in start_session'
    @status = 'Filled in get_status'
  end

  def start_session(type)
    @session_id = @payler.start_session(
      order_id: @order_id,
      type: type,
      cents: @order_amount,
      currency: @order_currency,
      lang: @lang,
    ).session_id
  end

  def pay
    perform_payment(@payler.pay_page_url(@session_id))
  end

  def request_status
    @status = @payler.get_status(@order_id)
  end

  # def test_pay_page_contains_product_name
  #   product_name = 'Тестовый продукт'
  #   @session_id = @payler.start_session(
  #     order_id: @order_id,
  #     type: SESSION_TYPES[:two_step],
  #     cents: @order_amount,
  #     currency: @order_currency,
  #     lang: @lang,
  #     product: product_name,
  #   ).session_id
  #   page.visit(@payler.pay_page_url(@session_id))
  #   assert page.has_content?(product_name)
  # end

  # def test_pay_page_contains_product_id_if_no_name_passed
  #   @session_id = @payler.start_session(
  #     order_id: @order_id,
  #     type: SESSION_TYPES[:two_step],
  #     cents: @order_amount,
  #     currency: @order_currency,
  #     lang: @lang,
  #   ).session_id
  #   page.visit(@payler.pay_page_url(@session_id))
  #   assert page.has_content?(@order_id)
  # end


  # def test_start_session_get_status_error_flow
  #   start_session(SESSION_TYPES[:two_step])

  #   begin
  #     request_status
  #   rescue ::RubyPayler::ResponseWithError => error
  #     assert_equal 603, error.code
  #     assert_equal 'Пользователь не предпринимал попыток оплаты.', error.message
  #   end
  #   assert error
  # end

  # def test_try_charge_more_than_authorized_error_flow
  #   start_session(SESSION_TYPES[:two_step])
  #   pay

  #   begin
  #     @payler.charge(@order_id, @order_amount + 1)
  #   rescue ::RubyPayler::ResponseWithError => error
  #     assert_equal 1, error.code
  #     assert_equal 'Неверно указана сумма транзакции.', error.message
  #   end
  #   assert error
  # end

  # def test_error_in_english_session
  #   @lang = LANGUAGES[:en]
  #   start_session(SESSION_TYPES[:two_step])

  #   begin
  #     request_status
  #   rescue ::RubyPayler::ResponseWithError => error
  #     assert_equal 603, error.code
  #     assert_equal 'User has not attempted to pay.', error.message
  #   end
  #   assert error
  # end
end
