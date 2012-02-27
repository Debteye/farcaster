class YodleeBankAccount < ActiveRecord::Base
  has_many :yodlee_bank_transactions, :foreign_key => 'yodlee_bank_account_id', :primary_key => 'yodlee_bank_account_id'
  belongs_to :yodlee_item, :foreign_key => "yodlee_item_id", :primary_key => "yodlee_item_id"
  belongs_to :yodlee_user

  validates_uniqueness_of :yodlee_bank_account_id
  FIELD_MAP = {
               #<input>         => <column_name>
               :bank_account_id => :yodlee_bank_account_id,
               :as_of_date => lambda {|value| value && value[:date] }
              }

  def bank_name
    yodlee_item.yodlee_data_provider.content_service_display_name
  end

  def self.generate(data_array, defaults = {})
    data_array = [data_array].flatten(1)
    keys = column_names.map(&:to_sym)
    bank_accounts = data_array.map do |element|
      next unless element[:bank_account_id]

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

      ba = find_by_yodlee_bank_account_id(data_hash[:yodlee_bank_account_id]) || new(data_hash)

      if element[:bank_transactions]
        transactions = YodleeBankTransaction.generate(element[:bank_transactions][:elements])
        ba.yodlee_bank_transactions = transactions
      end
      ba
    end
    bank_accounts
  end
end
