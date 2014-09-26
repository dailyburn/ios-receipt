class Ios::Receipt::Client
  ENDPOINTS = {
    production: 'https://buy.itunes.apple.com/verifyReceipt',
    sandbox: 'https://sandbox.itunes.apple.com/verifyReceipt'
  }
  
  def initialize(method=nil, secret=nil)
    method ||= :mixed
    @method = method
    @secret = secret
    
    raise Ios::Receipt::Exceptions::InvalidConfiguration unless valid_method?
  end
  
  def verify!(receipt)
    data = { 'receipt-data' => receipt }
    data['password'] = @secret unless @secret.nil?
    data = data.to_json
    
    response = nil
    response = post_to_endpoint(:production, data) if try_production?
    response = post_to_endpoint(:sandbox, data) if response.nil? && try_sandbox?
    
    response
  end
  
  protected
  
  def try_production?
    @method == :production || @method == :mixed
  end
  
  def try_sandbox?
    @method == :sandbox || @method == :mixed
  end
  
  def valid_method?
    try_production? || try_sandbox?
  end
  
  def post_to_endpoint(env, data)
    begin
      response = RestClient.post ENDPOINTS[env], data
      Ios::Receipt::Result.new JSON.parse(response), env
    rescue Ios::Receipt::Exceptions::SandboxReceipt => e
      raise Ios::Receipt::Exceptions::SandboxReceipt unless env == :production && try_sandbox?
      nil
    end
  end
end