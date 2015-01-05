class Ios::Receipt::Result
  attr_reader :result, :environment, :bundle_id, :application_version, :original_application_version,
              :in_app, :latest, :transaction_ids

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
      latest = result['latest_receipt_info'] || result['latest_expired_receipt_info']
      @latest = Ios::Receipt::Receipt.new(latest) if latest
    end

    @in_app = [receipt['in_app'] || []].flatten.compact.collect { |r| Ios::Receipt::Receipt.new r }
    @latest = [result['latest_receipt_info'] || []].flatten.compact.collect { |r| Ios::Receipt::Receipt.new r }
  end

  def recurring_receipts
    @recurring ||= @latest.select { |r| r.recurring? }
  end

  def once_off_receipts
    @once_offs ||= @latest.select { |r| r.once_off? }
  end
  
  def expired?
    @status == 21006
  end
  
  def sandbox?
    @environment == :sandbox
  end
  
  def production?
    @environment == :production
  end

  def active_recurring_receipts
    @active_recurring_receipts ||= recurring_receipts.select { |r| r.active? }
  end

  def next_recurring_receipt
    @next_recurring_receipt ||= active_recurring_receipts.sort_by { |r| r.expires_date }.first
  end

  def in_trial_receipts
    @in_trial_receipts ||= active_recurring_receipts.select { |r| r.in_trial? }
  end

  def transaction_ids
    (@in_app.collect { |r| r.transaction_id } + @latest.collect { |r| r.transaction_id }).flatten.compact.uniq
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
end