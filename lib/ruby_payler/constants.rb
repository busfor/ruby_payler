module RubyPayler
  module Constants
    SESSION_TYPES = {
      one_step: 'OneStep',
      two_step: 'TwoStep',
    }.freeze

    LANGUAGES = {
      ru: 'ru',
      en: 'en',
    }.freeze

    CURRENCIES = {
      rub: 'RUB',
      usd: 'USD',
      eur: 'EUR',
    }.freeze

    RESPONSE_STATUSES = {
      created: 'Created',
      pre_authorized_3ds: 'PreAuthorized3DS',
      authorized: 'Authorized',
      charged: 'Charged',
      refunded: 'Refunded',
      reversed: 'Reversed',
      rejected: 'Rejected',
    }.freeze
  end
end
