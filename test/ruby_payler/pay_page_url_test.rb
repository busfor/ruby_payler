require 'test_helper'

# Test that test_page_url methods returns expected url of payment page
class PayPageUrlTest < ActiveSupport::TestCase
  def test_pay_page_url
    key = '123'
    session_id = '321'
    payler = RubyPayler::Payler.new(
      host: 'host',
      key: key,
      password: 'password',
    )
    expected_url =
      "https://host.payler.com/gapi/Pay?key=#{key}&session_id=#{session_id}"

    assert_equal expected_url, payler.pay_page_url(session_id)
  end
end
