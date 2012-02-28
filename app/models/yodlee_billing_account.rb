class YodleeBillingAccount <  ActiveRecord::Base
  has_many :yodlee_bills, :foreign_key => "yodlee_billing_account_id", :primary_key => "yodlee_billing_account_id" 

  belongs_to :yodlee_item, :foreign_key => "yodlee_item_id", :primary_key => "yodlee_item_id"
  belongs_to :yodlee_user

  validates :yodlee_billing_account_id, :uniqueness => true

  FIELD_MAP = {
               #<input>         => <column_name>
               :billing_account_id => :yodlee_billing_account_id,
               :last_payment => lambda {|value| value && value[:amount]}, 
               :last_payment_date => lambda {|value| value && value[:date]},
              }

  def provider_name
    yodlee_item.yodlee_data_provider.content_service_display_name
  end

  def self.generate(data_array, defaults = {})
    data_array = [data_array].flatten(1)
    keys = column_names.map(&:to_sym)
    billing_accounts = data_array.map do |element|
      next unless element[:billing_account_id]
      transformed_element = defaults.merge(element.symbolize_keys)
      
      data_hash = transformed_element.inject({}) do |hash, (key, value)| 
        if field_map = FIELD_MAP[key] 
          case field_map
          when Symbol
            hash[field_map] = value
          when Proc
            hash[key] = field_map.call(value)
          end
        elsif keys.include?(key)
          hash[key] = value    
        end
        hash
      end

      ba = find_by_yodlee_billing_account_id(data_hash[:yodlee_billing_account_id]) || new
      ba.attributes = data_hash
      ba.save

      if element[:bills]
        bills = YodleeBill.generate(element[:bills][:elements])
        ba.yodlee_bills = bills
      end
 
      ba
    end
    billing_accounts
  end
end
