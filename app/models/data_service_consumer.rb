class DataServiceConsumer < ActiveRecord::Base
  before_create :generate_key
  
  def generate_key
    self.key ||= Digest::MD5.hexdigest Time.now.to_i.to_s
  end

  def handle_data_request(request_details)
    cust_arr = [request_details["Customers"]].flatten(1)

    response = cust_arr.map do |cust_hash| 
      email = cust_hash['Email']     
      if (customer = Customer.find_by_email(email)) && customer.yodlee_user
        yu = customer.yodlee_user
        {"CustomerDetails" => cust_hash,
         "CustomerData" => yu}
      else 
        {'ErrorMsg' => "No records found for this customer", "CustomerDetails" => cust_hash}
      end  
    end

    response.to_xml(:include => {:yodlee_card_accounts => {:include => {:yodlee_card_statements => {:include => :yodlee_card_bill}}}}, 
                    :except => excluded_columns, 
                    :root => "CustomerReturn",
                    :skip_instruct => true,
                    :camelize => true).gsub("Yodlee", "")
  end 


  def excluded_columns
    [
     :created_at, :id, :updated_at, :customer_id, :username, :password, :registered, :updating, :yodlee_item_id, :yodlee_user_id,
     :card_account_id, :item_account_id
    ]
  end
end
