require 'rest_client'
require 'ios/receipt/version'
require 'ios/receipt/exceptions'
require 'ios/receipt/client'
require 'ios/receipt/result'

module Ios
  module Receipt
    def self.verify!(receipt, method=nil, secret=nil)
      client = Ios::Receipt::Client.new method, secret
      client.verify! receipt
    end
  end
end
