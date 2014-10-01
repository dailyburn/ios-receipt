class Ios::Receipt::Result
  attr_reader :result, :environment, :bundle_id, :application_version, :original_application_version,
              :in_app, :expires_date, :original, :latest, :product_id

  def initialize(result, environment=nil)
    @result = result
    @status = result['status']
    check_status!
    
    @environment = (result['environment'] || environment).try(:downcase).try(:to_sym)
    raise Ios::Receipt::Exceptions::InvalidConfiguration if @environment.nil?

    receipt = result['receipt']
    @bundle_id = receipt['bid'] || receipt['bundle_id']
    @application_version = receipt['application_version']
    @original_application_version = receipt['original_application_version']
    if receipt['original_transaction_id'] # ios6 style receipt
      @original = {
        transaction_id: receipt['original_transaction_id'],
        purchase_date: parse_time(receipt['original_purchase_date']),
      }
      
      latest = result['latest_receipt_info'] || result['latest_expired_receipt_info']
      if latest
        @latest = {
          transaction_id: latest['transaction_id'],
          purchase_date: parse_time(latest['purchase_date']),
          expires_date: parse_time(latest['expires_date_formatted']),
          cancellation_date: parse_time(latest['cancellation_date'])
        }
      end
    end

    @in_app = []
    if receipt['in_app'] && receipt['in_app'].is_a?(Array)
      receipt['in_app'].each do |r|
        this_receipt = {
          quantity: r['quantity'],
          product_id: r['product_id'],
          transaction_id: r['transaction_id'],
          purchase_date: parse_time(r['purchase_date']),
          expires_date: parse_time(r['expires_date']),
          cancellation_date: parse_time(r['cancellation_date']),
          app_item_id: r['app_item_id'],
          version_external_identifier: r['version_external_identifier'],
          web_order_line_item_id: r['web_order_line_item_id'],
          is_trial_period: r['is_trial_period'] == 'true'
        }
        @original = this_receipt if @original.nil? && r['transaction_id'] == r['original_transaction_id']
        @in_app.push(this_receipt)
      end
    end
    @in_app = @in_app.sort_by { |r| r[:expires_date] }
    @latest ||= @in_app.last || {}
    @original ||= {}
    @product_id = receipt['product_id']
    
    @expires_date = [parse_time(receipt['expiration_date']), @latest[:expires_date]].compact.min
  end
  
  def in_trial?
    @latest.has_key?(:is_trial_period) && @latest[:is_trial_period]
  end
  
  def active?
    !inactive?
  end
  
  def inactive?
    expired? || cancelled?
  end
  
  def expired?
    return true if @status == 21006
    !!(@expires_date && @expires_date < Time.now)
  end
  
  def cancelled?
    latest_cancelled? || any_cancelled?
  end
  
  def transaction_ids
    ids = @in_app.collect { |a| a[:transaction_id] }
    ids.push(@original[:transaction_id]) if @original && @original[:transaction_id]
    ids.push(@latest[:transaction_id]) if @latest && @latest[:transaction_id]
    ids.uniq.compact
  end
  
  def sandbox?
    @environment == :sandbox
  end
  
  def production?
    @environment == :production
  end
  
  protected
  
  def check_status!
    case @status
    when 21000 then raise Ios::Receipt::Exceptions::Json
    when 21002 then raise Ios::Receipt::Exceptions::ReceiptFormat
    when 21003 then raise Ios::Receipt::Exceptions::ReceiptAuthentication
    when 21004 then raise Ios::Receipt::Exceptions::SharedSecret
    when 21005 then raise Ios::Receipt::Exceptions::ServerOffline
    when 21007 then raise Ios::Receipt::Exceptions::SandboxReceipt
    when 21008 then raise Ios::Receipt::Exceptions::ProductionReceipt
    end
  end
  
  def parse_time(string)
    return nil if string.blank?
    Time.parse string.sub('Etc/GMT', 'GMT')
  end
  
  def latest_cancelled?
    !@latest[:cancellation_date].nil?
  end
  
  def any_cancelled?
    any_cancelled = @in_app.detect { |a| !a[:cancellation_date].nil? }
    !any_cancelled.nil?
  end
end