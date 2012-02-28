class YodleeBill < ActiveRecord::Base
  belongs_to :yodlee_billing_account, :foreign_key => "yodlee_billing_account_id", :primary_key => "yodlee_billing_account_id"

  FIELD_MAP = {
               :bill_id => :yodlee_bill_id,
               :billing_account_id => :yodlee_billing_account_id,
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

  def self.generate(data_array, defaults = {})
    data_array = [data_array].flatten(1)
    keys = column_names.map(&:to_sym)
    statements = data_array.map do |element|
      next unless element[:bill_id]
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

      ba = find_by_yodlee_bill_id(data_hash[:yodlee_bill_id]) || new
      ba.attributes = data_hash
      ba.save unless ba.new_record?

      ba
    end
    statements
  end
end
