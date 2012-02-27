class YodleeBankTransaction < ActiveRecord::Base
  belongs_to :yodlee_bank_account, :foreign_key => "yodlee_bank_account_id", :primary_key => 'yodlee_bank_account_id'
  belongs_to :yodlee_transaction_category, :foreign_key => "transaction_category_id", :primary_key => "category_id"
  validates_uniqueness_of :yodlee_bank_transaction_id

  FIELD_MAP = {
               #<input>         => <column_name>
               :bank_account_id => :yodlee_bank_account_id,
               :bank_transaction_id => :yodlee_bank_transaction_id,
               :post_date => lambda {|value| value[:date] },
               :transaction_amount => lambda {|value| value[:amount]},
               :bank_statement_id => :yodlee_bank_statement_id
              }

  def frequency_result
    FrequencyResult.joins("inner join yodlee_transaction_groups ytg on frequency_results.reference_yodlee_bank_transaction_id = ytg.reference_yodlee_bank_transaction_id").
                    where("ytg.yodlee_bank_transaction_id = ?", yodlee_bank_transaction_id).first
  end

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

      ba = find_by_yodlee_bank_transaction_id(data_hash[:yodlee_bank_transaction_id]) || new(data_hash)
      ba
    end

    transactions
  end

  def date
    transaction_date || post_date
  end
end
