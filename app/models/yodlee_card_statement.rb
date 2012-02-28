class YodleeCardStatement < ActiveRecord::Base
  has_one :yodlee_card_bill, :foreign_key => "yodlee_card_bill_id", :primary_key => "yodlee_card_bill_id"
  FIELD_MAP = {
               :card_account_id => :yodlee_card_account_id,
               :card_statement_id => :yodlee_card_statement_id,
               :bill_id => :yodlee_card_bill_id,
              }

  def self.generate(data_array, defaults = {})
    data_array = [data_array].flatten(1)
    keys = column_names.map(&:to_sym)
    card_statements = data_array.map do |element|
      next unless element[:card_statement_id]
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

      ba = find_by_yodlee_card_statement_id(data_hash[:yodlee_card_statement_id]) || new
      ba.attributes = data_hash
      ba.save unless ba.new_record?

      if element[:bill]
        bill = YodleeCardBill.generate(element[:bill])
        ba.yodlee_card_bill = bill
      end
      ba
    end
    card_statements
  end

end
