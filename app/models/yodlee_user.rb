class YodleeUser < ActiveRecord::Base
  belongs_to :customer

  has_many :yodlee_items
   
  has_many :yodlee_user_data, :order => "created_at desc"
  has_many :yodlee_bank_accounts, :through => :yodlee_items
  has_many :yodlee_card_accounts, :through => :yodlee_items
  has_many :yodlee_bank_transactions, :through => :yodlee_bank_accounts, :conditions => "yodlee_bank_accounts.excluded is null or yodlee_bank_accounts.excluded = false"
  has_many :yodlee_card_transactions, :through => :yodlee_card_accounts, :conditions => "yodlee_card_accounts.excluded is null or yodlee_card_accounts.excluded = false"


end
