$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ruby_payler'

require 'minitest/autorun'

require 'pry-byebug'

require 'hashie'

require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

CONFIG = ::Hashie::Mash.new YAML::load(File.read('test/config.yml')).freeze

class CapybaraTestCase < Minitest::Test
  include Capybara::DSL

  def pay_by_capybara(pay_url)
    card = CONFIG.card
    puts "\n========= Capybara went to pay =========="
    page.visit(pay_url)
    page.fill_in 'PaylerCardNum', with: card.number
    page.fill_in 'PaylerExpired', with: card.valid_till
    page.fill_in 'PaylerCardholder', with: card.name
    page.fill_in 'PaylerCode', with: card.code
    page.click_button 'PaylerPostButton'
    puts "========= Capybara paid ==========\n"
  end

  def pay_by_hand(pay_url)
    puts "\n========= Please go pay, than press Enter =========="
    puts pay_url
    puts "====================================================\n"
    gets
  end

  def pay(pay_url)
    if CONFIG.use_capybara == true
      pay_by_capybara(pay_url)
    else
      pay_by_hand(pay_url)
    end
  end

  def teardown
    Capybara.reset_sessions!
  end
end

Capybara.default_driver = :poltergeist
Capybara.javascript_driver = :poltergeist
