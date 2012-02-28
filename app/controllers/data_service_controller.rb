class DataServiceController < ApplicationController
  skip_before_filter :verify_authenticity_token

=begin

sample

<?xml version="1.0" encoding="UTF-8"?>
<DataServiceRequest>
  <DataServiceConsumer>
    <Name>test</Name>
    <Key>f7d7381696f2af1049d283029cf9d859</Key>
  </DataServiceConsumer>
</DataServiceRequest>
=end

  def retrieve
    body = request.body.read
    if !body.blank? && hash = Nori.parse(body)['DataServiceRequest']

      dsc = hash['DataServiceConsumer']

      if dsc && consumer = authenticate(dsc) 
        req_details = hash['RequestDetails']
        data = consumer.handle_data_request(req_details) if req_details
        return render :xml => "<DataServiceResponse>\n#{data}</DataServiceResponse>"
      end
    end 

    return render :xml => {'ErrorCode' => 401, 'ErrorMsg' => 'Data Service Consumer Not Found'}.to_xml(:root => "DataServiceResponse"), :status => 401
  end


  private

  def authenticate(dsc)
    name = dsc['Name']
    key = dsc['Key']
    DataServiceConsumer.where(:name => name).where(:key => key).first
  end
end
