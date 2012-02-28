class YodleeCardBill < ActiveRecord::Base
  belongs_to :yodlee_card_statement, :foreign_key => "yodlee_card_bill_id", :primary_key => "yodlee_card_bill_id"

  FIELD_MAP = {
               :bill_id => :yodlee_card_bill_id,
               :ending_balance => lambda {|value| value && value[:amount]},
               :past_due => lambda {|value| value && value[:amount]},
               :amount_due => lambda {|value| value && value[:amount]},
               :min_payment => lambda {|value| value && value[:amount]}, 
               :last_payment => lambda {|value| value && value[:amount]}, 
               :paym_recvd_date => lambda {|value| value && value[:date]},
               :bill_period_end_date => lambda {|value| value && value[:date]},
               :paym_date => lambda {|value| value && value[:date]},
               :bill_period_start_date => lambda {|value| value && value[:date]},
               :bill_date => lambda {|value| value && value[:date]},
               :due_date => lambda {|value| value && value[:date]},
               :last_pay_date => lambda {|value| value && value[:date]}
              }

  def self.generate(element, defaults = {})
    return nil unless element
    keys = column_names.map(&:to_sym)
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

    statement = find_by_yodlee_card_bill_id(data_hash[:yodlee_card_bill_id]) || new
    statement.attributes = data_hash
    statement.save unless statement.new_record?
    statement
  end
end
