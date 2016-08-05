# RubyPayler
Ruby wrapper for payler.com API

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

## Usage
```ruby
# Create and initialize RubyPayler object with payler credentials
payler = RubyPayler::Payler.new(
  host: 'sandbox',
  key: 'aaaa-bbbb-ccc-ddd-eeeee',
  password: 'AaaBBbccC'
)

# Start session to pay given order
session_id = payler.start_session(
  order_id: 'order-12345',
  type: RubyPayler::SESSION_TYPES[:two_step], # one_step, two_step
  cents: 111,
  currency: RubyPayler::CURRENCIES[:rub], # rub, usd, eur
  lang: RubyPayler::LANGUAGES[:ru], # ru, en
).session_id

# Get url of payment page and redirect user to it
redirect_to payler.pay_page_url(session_id)

# User paid for order and Payler redirects it back to shop
status = payler.get_status(order_id)
# status.status = 'Authorized' for successfull TwoStep payment
# status.status = 'Charged' for successfull OneStep payment

# Charge authorized money for TwoStep payment
payler.charge(order_id, order_amount) # status => 'Charged'

# Retrieve authorized money for TwoStep payment
payler.retrieve(order_id, order_amount) # Status => 'Reversed'

# Refund already charged money
payler.refund(order_id, order_amount) # Status => 'Refunded'
```

See tests for more usage examples

## Errors
In case of any error RubyPayler `raises` RubyPayler::Error having code and message

## Tests
Tests make real calls to Payler.com web API.

Payment step in tests is automated with Capybara and PhantomJS.

You can switch to make Payment step by hand via config file

## Config
Make file config.yml by copying config_example.yml

Fill in your Payler key, password, host

Fill test card number, vaild_till, code, name for automated payment by capybara

Change use_capybara to false to make payment by hand

## Development
To run automated tests with capybara install PhantomJS

brew install phantomjs on MacOS

To experiment with that code, run `bin/console` for an interactive prompt.

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/busfor/ruby_payler. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

