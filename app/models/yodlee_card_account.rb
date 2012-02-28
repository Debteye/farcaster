class YodleeCardAccount <  ActiveRecord::Base
  has_many :yodlee_card_transactions, :foreign_key => 'yodlee_card_account_id', :primary_key => 'yodlee_card_account_id'
  has_many :yodlee_card_statements, :foreign_key => "yodlee_card_account_id", :primary_key => "yodlee_card_account_id" 

  has_many :yodlee_card_bills, :through => :yodlee_card_statements, :order => "due_date desc nulls last"

  belongs_to :yodlee_item, :foreign_key => "yodlee_item_id", :primary_key => "yodlee_item_id"
  belongs_to :yodlee_user
  has_one :debt

  validates :yodlee_card_account_id, :uniqueness => true
  FIELD_MAP = {
               #<input>         => <column_name>
               :card_account_id => :yodlee_card_account_id,
               :running_balance => lambda {|value| value && value[:amount]}, 
               :available_credit => lambda {|value| value && value[:amount]},
               :total_credit_line => lambda {|value| value && value[:amount]},
               :available_cash => lambda {|value| value && value[:amount]},  
               :total_cash_limit => lambda {|value| value && value[:amount]},
              }

  def provider_name
    yodlee_item.yodlee_data_provider.content_service_display_name
  end

  def self.generate(data_array, defaults = {})
    data_array = [data_array].flatten(1)
    keys = column_names.map(&:to_sym)
    card_accounts = data_array.map do |element|
      next unless element[:card_account_id]
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

      ba = find_by_yodlee_card_account_id(data_hash[:yodlee_card_account_id]) || new
      ba.attributes = data_hash
      ba.save

      if element[:card_transactions]
        transactions = YodleeCardTransaction.generate(element[:card_transactions][:elements])
        ba.yodlee_card_transactions = transactions
      end
 
      if element[:card_statements]
        statements = YodleeCardStatement.generate(element[:card_statements][:elements])
        ba.yodlee_card_statements = statements
      end
 
      ba
    end
    card_accounts
  end
end
