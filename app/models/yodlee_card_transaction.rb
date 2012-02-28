class YodleeCardTransaction < ActiveRecord::Base
  belongs_to :yodlee_card_account, :foreign_key => "yodlee_card_account_id", :primary_key => 'yodlee_card_account_id'
  belongs_to :yodlee_transaction_category, :foreign_key => "transaction_category_id", :primary_key => "category_id"
  validates :yodlee_card_transaction_id, :uniqueness => true

  FIELD_MAP = {
               #<input>         => <column_name>
               :card_account_id => :yodlee_card_account_id,
               :card_transaction_id => :yodlee_card_transaction_id, 
               :post_date => lambda {|value| value && value[:date] },
               :trans_date => lambda {|value| value && value[:date] },
               :trans_amount => lambda {|value| value && value[:amount]},
               :card_statement_id => :yodlee_card_statement_id
              }

  def self.generate(data_array, defaults = {})
    data_array = [data_array].flatten(1)

    keys = column_names.map(&:to_sym)

    transactions = data_array.map do |element|
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
 
      data_hash = defaults.merge(data_hash)  
 
      ba = find_by_yodlee_card_transaction_id(data_hash[:yodlee_card_transaction_id]) || new(data_hash)
      ba
    end
  
    transactions
  end

  def transaction_date
    trans_date
  end

  def transaction_amount
    trans_amount
  end

  def date
    transaction_date || post_date
  end

end
