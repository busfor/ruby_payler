# RubyPayler
Ruby wrapper for payler.com API

_Not all methods, parameters are implemented. There's an issue about that and I'm going to resolve it a bit later._

Documentation for API is here: http://payler.com/docs/acquiring.html

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
There are two child types of Errors:
- FailedRequest - for failed network request (FaradayError)
- ResponseWithError - for response with status != 200 and error in body

ResponseWithError objects has methods to access _error_, _code_, _message_ of error returned in resonse.

## Tests
*Tests make real calls to Payler.com web API.*

Cool, because it really test workflows of interaction with payler equiring via ruby_payler gem. If payler API changes, tests will brake. So, if all tests are passing, tandem of payler and gem is working fine.

Payment step in tests is automated with Capybara and PhantomJS (cool as well).

You can switch to make Payment step by hand via config file (use_capybara: false).

## Config
Make file config.yml by copying config_example.yml

Fill in your Payler key, password, host

Fill test card number, vaild_till, code, name for automated payment by capybara

Change use_capybara to false to make payment by hand

## Development
To run automated tests with capybara install PhantomJS (_brew install phantomjs on MacOS_)

To experiment with that code, run `bin/console` for an interactive prompt.

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/busfor/ruby_payler. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

