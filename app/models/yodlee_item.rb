class YodleeItem < ActiveRecord::Base
  belongs_to :yodlee_user
  belongs_to :yodlee_data_provider, :primary_key => "content_service_id", :foreign_key => "content_service_id"
  belongs_to :yodlee_item_status

  has_many :yodlee_bank_transactions, :through => :yodlee_bank_accounts
  has_many :yodlee_card_transactions, :through => :yodlee_card_accounts

  has_many :yodlee_bank_accounts, :foreign_key => "yodlee_item_id", :primary_key => "yodlee_item_id"
  has_many :yodlee_card_accounts, :foreign_key => "yodlee_item_id", :primary_key => "yodlee_item_id"
  
  scope :banks, joins(:yodlee_data_provider).where('yodlee_data_providers.provider_type' => "bank")
  scope :verified, where(:verification_status => "SUCCESS")
end
