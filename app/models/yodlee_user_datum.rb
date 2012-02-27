require 'nori'

class YodleeUserDatum < ActiveRecord::Base
  belongs_to :yodlee_user

  def to_hash
    if response
      begin
        @hash ||= Nori.parse(response)[:envelope][:body][:get_item_summaries3_response][:get_item_summaries3_return][:elements]
      rescue
        @hash ||= Nori.parse(response)[:envelope][:body][:get_item_summaries2_response][:get_item_summaries2_return][:elements]
      end
    end
  end
end
