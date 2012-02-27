require 'halberd'
require 'gibberish'

class YodleeUser < ActiveRecord::Base
  has_many :yodlee_items

  has_many :yodlee_user_data, :order => "created_at desc"
  has_many :yodlee_bank_accounts
  has_many :yodlee_bank_transactions, :through => :yodlee_bank_accounts


  def self.bulk_update!
    all.each do |user|
      user.delay.get_detailed_summary!
    end
  end

  def self.test_user!
    user = new(:username => :debteye_27, :password => "yodpass-1.828e-06-1.84e-06", :registered => true)
    user.save
    item = user.yodlee_items.build(:yodlee_data_provider_id => 670, :yodlee_item_id => 11033579, :hash => "54874d68ac83fc4c99d59f3b0e5e240e")
    item.save
    user
  end

  def secret
    ENV['YODLEE_SECRET'] || "debteye-yodlee"
  end

  def cipher
    @cipher ||= Gibberish::AES.new(secret)
  end

  def ciphered_password
    self['password']
  end

  def ciphered_password=(ciphered_password)
    self['password'] = ciphered_password
  end

  def password=(password)
    self['password'] = cipher.enc(password)
  end

  def password=(password)
    self['password'] = cipher.enc(password)
  end

  def password
    cipher.dec(self['password'])
  end
 
  def generate_credentials
    self.username = customer ? "debteye_#{customer.id}" : "debteye_#{Time.now.to_i}"
    self.password = "yodpass#{Time.now - Time.now}#{Time.now - Time.now}"
    true
  end

  def register! 
    client.register!
    self.registered = true if client.logged_in?
  end
   
  def registered?
    self.registered
  end

  def login!
    client(true).login!
  end
  
  def get_summary
    login! #unless logged_in?
    resp = client.items_interface.get_summary!
    data = YodleeUserDatum.new
    data.response = resp.to_xml
    data
  end
 
  def get_detailed_summary! 
    if username != "debteye_foo"
      login! #unless logged_in?
      resp = client.items_interface.get_detailed_summary!
      data = yodlee_user_data.first || yodlee_user_data.build
      data.response = resp.to_xml
    else
      resp = File.read(Rails.root.join("etc/yodlee/yodlee_user_datum.csv"))
      data = yodlee_user_data.first || yodlee_user_data.build
      data.response = resp
    end

    hash = data.to_hash

    if hash.is_a?(Array)
      hash.each do |ele|
         [ele[:refresh_info]].flatten.each do |refresh_info|
           puts refresh_info.inspect
           if item = yodlee_items.find_by_yodlee_item_id(refresh_info[:item_id])
             item.verification_status = refresh_info[:last_data_update_attempt][:status]
             item.data_update_time = refresh_info[:last_data_update_attempt][:date]
             puts item.save
           end
         end
      end
    else
      [hash[:refresh_info]].flatten.each do |refresh_info|
        puts refresh_info.inspect
        if item = yodlee_items.find_by_yodlee_item_id(refresh_info[:item_id])
          item.verification_status = refresh_info[:last_data_update_attempt][:status]
          item.data_update_time = refresh_info[:last_data_update_attempt][:date]
          puts item.save
        end
      end
    end
    data.save
    data
  end

  def update_verification_information!
    login! unless logged_in?
    resp = client.items_interface.instant_account_verification_status
    arr = [resp.to_hash[:get_item_verification_data_response][:get_item_verification_data_return][:elements]].flatten(1)

    arr.each do |element|
      info = element[:item_verification_info]
      puts element.inspect

      item = yodlee_items.find_by_yodlee_item_id(info[:item_id])
      item.update_attribute(:verification_status, info[:request_status]) if item
    end

    yodlee_items.reload
  end

  def update_item_statuses!
    data = get_summary
    [data.to_hash].flatten(1).each do |element|
      item = yodlee_items.find_by_yodlee_item_id(element[:item_id])
      if element[:refresh_info]
        update_attempt = element[:refresh_info][:last_data_update_attempt] || element[:refresh_info][:last_user_requested_data_update_attempt]
        item.update_attribute(:verification_status, update_attempt[:status])
      end
    end
    yodlee_items.reload
    yodlee_items
  end

  def update_items!
    data = get_detailed_summary!
    bank_accounts = data_to_bank_accounts(data)
    bank_accounts.flatten!
    bank_accounts.compact!
    self.yodlee_bank_accounts = bank_accounts
    self.save
    da = DataAnalyzer.new(self)
    da.run_analysis
  end

  def data_to_bank_accounts(data)
    items = [data.to_hash].flatten(1)
    bank_accounts = items.map do |item|
      if item[:item_data] && item[:item_data][:accounts]
        YodleeBankAccount.generate(item[:item_data][:accounts][:elements], :yodlee_item_id => item[:item_id])
      end
    end
    bank_accounts
  end

  def register_item!(content_service_id, credentials)
    items_interface = client.items_interface

    item_id = items_interface.register!(content_service_id, :credentials => credentials)

    puts item_id

    item = yodlee_items.build(:yodlee_item_id => item_id)
    credential_seed = credentials.map {|c| c[:value]} 
    item.hash = Digest::MD5.hexdigest("#{content_service_id}#{credential_seed.to_s}")
    item.yodlee_data_provider = YodleeDataProvider.where(:content_service_id => content_service_id).first

    client.item_ids << item_id
    item.save
    item
  end

  def has_item?(content_service_id, credentials)
    if Rails.env.production?
      credential_seed = credentials.map {|c| c[:value]} 
      yodlee_items.exists?(:hash => Digest::MD5.hexdigest("#{content_service_id}#{credential_seed.to_s}"))
    else
      !yodlee_items.empty?
    end
  end

  def logged_in?
    client.logged_in?
  end

  def client(flush = false)
    @client = nil if flush
    @client ||= begin 
      client = Halberd::Us.new
      client.connect!
      spawn = client.spawn
      spawn.username = username
      spawn.password = password
      spawn.item_ids = yodlee_items.map {|yi| yi.yodlee_item_id}
      spawn
    end
  end
end
