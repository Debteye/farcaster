class YodleeTransactionCategory < ActiveRecord::Base
  validates_uniqueness_of :category_id
  scope :relevant_bills, where("category_name not in (?)", ["ATM/Cash Withdrawals",
                                                            "General Merchandise",
                                                            "Service Charges/Fees",
                                                            "Gasoline/Fuel",
                                                            "Transfers",
                                                            "Travel",
                                                            "Groceries",
                                                            "Restaurants/Dining",
                                                            "Interest"])

  scope :forced_monthly_bills, where("category_name in (?)", ['Credit Card Payments', 
                                                              'Utilities',
                                                              'Cable/Satellite Services',
                                                              'Telephone Services'
                                                             ])

  def self.generate_categories
    us = Halberd::Us.new
    us.connect!
    interface = us.get_interface
    response = interface.get_category_list

    categories = response.to_hash[:get_supported_transaction_categrories_response][:get_supported_transaction_categrories_return][:elements]

    common_keys = nil
    attribute_keys = column_names.map(&:to_sym)
    categories.map! do |category|
      common_keys ||= category.keys & attribute_keys
      data = category.select {|k,v| common_keys.include?(k)}
      new(data)
    end
    categories
  end

  def self.populate!
    categories = generate_categories
    categories.each {|c| c.save}
  end
end
