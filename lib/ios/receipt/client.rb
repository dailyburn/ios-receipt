class Ios::Receipt::Client
  ENDPOINTS = {
    production: 'https://buy.itunes.apple.com/verifyReceipt',
    sandbox: 'https://sandbox.itunes.apple.com/verifyReceipt'
  }
  
  def initialize(method=nil, secret=nil, ssl_version='TLSv1')
    method ||= :mixed
    @method = method
    @secret = secret
    @ssl_version = ssl_version
    
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
    [:mixed, :production].include? @method
  end
  
  def try_sandbox?
    [:mixed, :sandbox].include? @method
  end
  
  def valid_method?
    try_production? || try_sandbox?
  end
  
  def post_to_endpoint(env, data)
    begin
      response = RestClient::Request.execute method: :post, url: ENDPOINTS[env], payload: data, ssl_version: @ssl_version
      Ios::Receipt::Result.new JSON.parse(response), env
    rescue Ios::Receipt::Exceptions::SandboxReceipt => e
      raise Ios::Receipt::Exceptions::SandboxReceipt unless env == :production && try_sandbox?
      nil
    end
  end
end