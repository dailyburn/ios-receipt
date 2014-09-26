module Ios
  module Receipt
    module Exceptions
      class Exception < Exception; end
      class InvalidConfiguration < Ios::Receipt::Exceptions::Exception; end
      class Json < Ios::Receipt::Exceptions::Exception; end
      class ReceiptFormat < Ios::Receipt::Exceptions::Exception; end
      class ReceiptAuthentication < Ios::Receipt::Exceptions::Exception; end
      class SharedSecret < Ios::Receipt::Exceptions::Exception; end
      class ServerOffline < Ios::Receipt::Exceptions::Exception; end
      class SandboxReceipt < Ios::Receipt::Exceptions::Exception; end
      class ProductionReceipt < Ios::Receipt::Exceptions::Exception; end
    end
  end
end
