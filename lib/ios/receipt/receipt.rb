class Ios::Receipt::Receipt
  attr_reader :quantity, :product_id, :original_transaction_id, :transaction_id, :original_purchase_date,
    :purchase_date, :expires_date, :cancellation_date, :app_item_id, :version_external_identifier, 
    :web_order_line_item_id, :is_trial_period

  def initialize(receipt_hash)
    @quantity = receipt_hash['quantity']
    @product_id = receipt_hash['product_id']
    @original_transaction_id = receipt_hash['original_transaction_id']
    @transaction_id = receipt_hash['transaction_id']
    @original_purchase_date = parse_time receipt_hash['original_purchase_date']
    @purchase_date = parse_time receipt_hash['purchase_date']
    @expires_date = parse_time receipt_hash['expires_date']
    @cancellation_date = parse_time receipt_hash['cancellation_date']
    @app_item_id = receipt_hash['app_item_id']
    @version_external_identifier = receipt_hash['version_external_identifier']
    @web_order_line_item_id = receipt_hash['web_order_line_item_id']
    @is_trial_period = receipt_hash['is_trial_period'] == 'true'
  end

  def once_off?
    @expires_date.nil?
  end

  def recurring?
    !once_off?
  end

  def active?
    !cancelled? && !expired?
  end

  def expired?
    return false unless recurring?
    !!(@expires_date && @expires_date < Time.now)
  end

  def cancelled?
    !@cancellation_date.nil?
  end

  def in_trial?
    @is_trial_period
  end

  private

  def parse_time(str)
    return nil if str.nil? || str == ''

    if !str.match(/^[0-9]+$/).nil? # It's in number format
      Time.at(str.to_i / 1000)
    else # They've sent it in string format
      Time.parse(str.sub('Etc/GMT', 'GMT')) rescue nil
    end
  end
end