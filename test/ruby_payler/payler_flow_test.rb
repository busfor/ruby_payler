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
    @order_id = "test_#{DateTime.now.strftime('%Y-%m-%d-%N')}"
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
end
