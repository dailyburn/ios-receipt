# IosReceipt

ios-receipt is a RubyGem to manage validating and parsing iOS purchase receipts.

## Installation

Add this line to your application's Gemfile:

    gem 'ios-receipt'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ios-receipt

## Usage

result = Ios::Receipt.verify! encoded_receipt, mode, ENV['IOS_SHARED_SECRET']
mode can be one of :sandbox, :production, or :mixed (try both)
result.latest returns all receipts
Each receipt object has fields: :quantity, :product_id, :original_transaction_id, :transaction_id, :original_purchase_date,
    :purchase_date, :expires_date, :cancellation_date, :app_item_id, :version_external_identifier, 
        :web_order_line_item_id, :is_trial_period

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
