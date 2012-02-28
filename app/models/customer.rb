class Customer < ActiveRecord::Base
  has_one :yodlee_user
  belongs_to :person

  def self.find_by_email(email)
    find(:first, :conditions => ["people.email = ?", email], :joins => "inner join people on person_id = people.id")
  end
end
