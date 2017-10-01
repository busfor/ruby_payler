# RubyPayler
Ruby wrapper for payler.com Gate API v1.11

_This is not Merchant API_


Documentation for API is here: [pdf](http://payler.com/download/docs/%D0%9E%D0%BF%D0%B8%D1%81%D0%B0%D0%BD%D0%B8%D0%B5%20Payler%20Gate%20API.pdf) and here: http://payler.com/docs/acquiring.html

Documentation for this gem: http://www.rubydoc.info/gems/ruby_payler/

## Highlights
- 100% of API methods implemented
- 100% test coverage
- tests perform real interactions with Payler API via Capybara and PhantomJs
- tests work fast and offline with VCR cassettes
- battle-tested at [busfor.ru](https://busfor.ru), more than 200000 payments processed

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby_payler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby_payler

## General considerations on usage
- All methods return mashified response.body, see [Hashie::Mash](https://github.com/intridea/hashie#mash)
- Some parameters to methods are not required. Omit if you don't need them.


## Usage
```ruby
# Require Constants to use them
require RubyPayler::Constants

# Create and initialize RubyPayler object with payler credentials
payler = RubyPayler::Payler.new(
  host: 'sandbox',
  key: 'aaaa-bbbb-ccc-ddd-eeeee',
  password: 'AaaBBbccC'
)

# Start session to pay given order
session_id = payler.start_session(
  order_id: 'order-12345',
  type: SESSION_TYPES[:two_step], # one_step, two_step
  cents: 111,
  currency: CURRENCIES[:rub], # rub, usd, eur
  lang: LANGUAGES[:ru], # ru, en
  product: 'Product name', # not required
  userdata: 'any data string to get later via get_advanced_status', # not required
).session_id

# Get url of payment page and redirect user to it
redirect_to payler.pay_page_url(session_id)

# User paid for order and Payler redirects it back to shop
status = payler.get_status(order_id)
# status.status = RESPONSE_STATUSES[:authorized] for successfull TwoStep payment
# status.status = RESPONSE_STATUSES[:charged] for successfull OneStep payment

# More data, including passed userdata
status = payler.get_advanced_status(order_id)

# Charge authorized money for TwoStep payment
payler.charge(order_id, order_amount) # status => RESPONSE_STATUSES[:charged]

# Retrieve authorized money for TwoStep payment
payler.retrieve(order_id, order_amount) # status => RESPONSE_STATUSES[reversed]

# Refund already charged money
payler.refund(order_id, order_amount) # status => RESPONSE_STATUSES[refunded]
```

See tests for more usage examples

## Errors
In case of any error RubyPayler `raises` RubyPayler::Error.
There are three child types of Errors:
- ResponseError - for responses with error in body
- NetworkError - for failed network request
- UnexpectedResponseError - for responses with status != 200 but without error in body

All RubyPayler errors have methods _code_, _message_ and _to_s_

Examples of errors `to_s`:
- ResponseError: `Payler responded with error: Invalid amount of the transaction., code 1`
- NetworkError: `NetworkError occured while performing request to Payler: #<Faraday::Error: Faraday::Error>`
- UnexpectedResponseError: `Unexpected response: code - 503, body - `

## Tests
*Tests make real calls to Payler.com web API.*

Cool, because it really test workflows of interaction with payler equiring via ruby_payler gem. If payler API changes, tests will brake. So, if all tests are passing, tandem of payler and gem is working fine.

Payment step in tests is automated with Capybara and PhantomJS (cool as well).

You can also switch to make Payment step by hand via ENV variable.

```bash
REFRESH_CAPYBARA=1 rake test # Regenerate VCR-cassettes using capybara to pay
REFRESH_BY_HAND=1 rake test # Regenerate VCR-cassettes paying by hand
```

After VCR-cassettes are saved launch `rake test` for fast test run

## Coverage
**Current test coverage is 100%**

To rebuild coverage report use `COVERAGE=1 rake test` command

## Config
Make file config.yml by copying config_example.yml

Fill in your Payler key, password, host

Fill test card number, vaild_till, code, name for automated payment by capybara

## Note on Pay method
This gem has methods `pay_page_url` instead of `pay` method, mentioned in Payler docs.

This is due to a fact that `pay` method does in fact return payment page url, and does not do any paying.

## Development
To run automated tests with capybara install PhantomJS (_brew install phantomjs on MacOS_)

To experiment with that code, run `bin/console` for an interactive prompt.

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/busfor/ruby_payler. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## Changelog
[Changelog](CHANGELOG.md)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

