$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

COVERAGE = ENV['COVERAGE']
REFRESH_CAPYBARA = ENV['REFRESH_CAPYBARA'] || ENV['REFRESH_BY_CAPYBARA']
REFRESH_BY_HAND = ENV['REFRESH_BY_HAND']

if COVERAGE
  require 'simplecov'
  SimpleCov.start
end

require 'ruby_payler'

require 'minitest/autorun'
require 'mocha/mini_test'
require 'capybara/minitest'
require 'capybara/poltergeist'
require 'pry-byebug'

require 'vcr'
VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :faraday
  config.ignore_localhost = true
end

require 'hashie'
CONFIG = ::Hashie::Mash.new YAML.safe_load(File.read('test/config.yml')).freeze

if REFRESH_CAPYBARA || REFRESH_BY_HAND
  FileUtils.rm_rf('fixtures/vcr_cassettes/capybara/.', secure: true)
end

# Base class for Payment flow where capybara performs payment
class CapybaraTestCase < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  def pay_by_capybara(pay_url)
    card = CONFIG.card
    puts "\n========= Capybara is going to pay =========="
    page.visit(pay_url)
    page.fill_in 'PaylerCardNum', with: card.number
    page.fill_in 'PaylerExpired', with: card.valid_till
    page.fill_in 'PaylerCardholder', with: card.name
    page.fill_in 'PaylerCode', with: card.code
    page.click_button 'PaylerPostButton'
    puts "============= Capybara has paid =============\n"
  end

  def pay_by_hand(pay_url)
    puts "\n===== Please go pay, than press Enter ======="
    puts pay_url
    puts "===============================================\n"
    gets
  end

  def perform_payment(pay_url)
    if REFRESH_CAPYBARA
      pay_by_capybara(pay_url)
    elsif REFRESH_BY_HAND
      pay_by_hand(pay_url)
    end
  end

  def teardown
    Capybara.reset_sessions!
  end
end

Capybara.default_driver = :poltergeist
Capybara.javascript_driver = :poltergeist
