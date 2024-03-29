class DataServiceController < ApplicationController
  skip_before_filter :verify_authenticity_token

=begin

sample

<?xml version="1.0" encoding="UTF-8"?>
<DataServiceRequest>
  <DataServiceConsumer>
    <Name>test</Name>
    <Key>9e0a32eac9c59d64324a04aabe93c7fd</Key>
  </DataServiceConsumer>
  <RequestDetails>
    <Customers type="array">
      <Customer>
        <Email>test@test.com</Email>
      </Customer>
      <Customer>
        <Email>test1330415600@test.com</Email>
      </Customer>
      <Customer>
        <Email>test2@test.com</Email>
      </Customer>
    </Customers>
  </RequestDetails>
</DataServiceRequest>

<?xml version='1.0' encoding='UTF-8'?>
<DataServiceResponse>
<Customers type="array">
  <Customer>
    <CustomerDetails>
      <Email>test@test.com</Email>
    </CustomerDetails>
    <CustomerData>
      <CardAccounts type="array">
        <CardAccount>
          <CardAccountId type="integer">10349291</CardAccountId>
          <AcctType>unknown</AcctType>
          <AccountNumber>XXXXXXXXXXXX7096</AccountNumber>
          <AccountName>BankAmericard Cash</AccountName>
          <AnnualPercentYield nil="true"></AnnualPercentYield>
          <RunningBalance type="decimal">0.0</RunningBalance>
          <AvailableCredit type="decimal">10000.0</AvailableCredit>
          <TotalCreditLine type="decimal">10000.0</TotalCreditLine>
          <AvailableCash type="decimal">3000.0</AvailableCash>
          <TotalCashLimit type="decimal">3000.0</TotalCashLimit>
          <CardBills type="array">
            <CardBill>
              <CardBillId type="integer">15067917</CardBillId>
              <IsHistoric type="boolean">false</IsHistoric>
              <AcctType>card</AcctType>
              <MarkAsPaidReason>unknown</MarkAsPaidReason>
              <AccountNumber>XXXXXXXXXXXX7096</AccountNumber>
              <DerivedPaymStatus>paid</DerivedPaymStatus>
              <EndingBalance type="decimal">9.5</EndingBalance>
              <PastDue type="decimal">0.0</PastDue>
              <AmountDue type="decimal" nil="true"></AmountDue>
              <MinPayment type="decimal">9.5</MinPayment>
              <LastPayment type="decimal" nil="true"></LastPayment>
              <IsDueDateEstimated type="boolean" nil="true"></IsDueDateEstimated>
              <PaymRecvdDate type="date" nil="true"></PaymRecvdDate>
              <BillPeriodEndDate type="date" nil="true"></BillPeriodEndDate>
              <PaymDate type="date" nil="true"></PaymDate>
              <BillPeriodStartDate type="date" nil="true"></BillPeriodStartDate>
              <BillDate type="date">2012-02-03</BillDate>
              <DueDate type="date">2012-03-02</DueDate>
              <LastPayDate type="date" nil="true"></LastPayDate>
              <PaymType>unknown</PaymType>
              <PaymStatus>unknown</PaymStatus>
              <IsDueOnReceipt type="boolean">false</IsDueOnReceipt>
              <UserPaymStatus>unknown</UserPaymStatus>
              <AccountName>BankAmericard Cash</AccountName>
            </CardBill>
          </CardBills>
        </CardAccount>
      </CardAccounts>
      <BillingAccounts type="array"/>
    </CustomerData>
  </Customer>
  <Customer>
    <CustomerDetails>
      <Email>test1330415600@test.com</Email>
    </CustomerDetails>
    <CustomerData>
      <CardAccounts type="array">
        <CardAccount>
          <CardAccountId type="integer">10349291</CardAccountId>
          <AcctType>unknown</AcctType>
          <AccountNumber>XXXXXXXXXXXX7096</AccountNumber>
          <AccountName>BankAmericard Cash</AccountName>
          <AnnualPercentYield nil="true"></AnnualPercentYield>
          <RunningBalance type="decimal">0.0</RunningBalance>
          <AvailableCredit type="decimal">10000.0</AvailableCredit>
          <TotalCreditLine type="decimal">10000.0</TotalCreditLine>
          <AvailableCash type="decimal">3000.0</AvailableCash>
          <TotalCashLimit type="decimal">3000.0</TotalCashLimit>
          <CardBills type="array">
            <CardBill>
              <CardBillId type="integer">15067917</CardBillId>
              <IsHistoric type="boolean">false</IsHistoric>
              <AcctType>card</AcctType>
              <MarkAsPaidReason>unknown</MarkAsPaidReason>
              <AccountNumber>XXXXXXXXXXXX7096</AccountNumber>
              <DerivedPaymStatus>paid</DerivedPaymStatus>
              <EndingBalance type="decimal">9.5</EndingBalance>
              <PastDue type="decimal">0.0</PastDue>
              <AmountDue type="decimal" nil="true"></AmountDue>
              <MinPayment type="decimal">9.5</MinPayment>
              <LastPayment type="decimal" nil="true"></LastPayment>
              <IsDueDateEstimated type="boolean" nil="true"></IsDueDateEstimated>
              <PaymRecvdDate type="date" nil="true"></PaymRecvdDate>
              <BillPeriodEndDate type="date" nil="true"></BillPeriodEndDate>
              <PaymDate type="date" nil="true"></PaymDate>
              <BillPeriodStartDate type="date" nil="true"></BillPeriodStartDate>
              <BillDate type="date">2012-02-03</BillDate>
              <DueDate type="date">2012-03-02</DueDate>
              <LastPayDate type="date" nil="true"></LastPayDate>
              <PaymType>unknown</PaymType>
              <PaymStatus>unknown</PaymStatus>
              <IsDueOnReceipt type="boolean">false</IsDueOnReceipt>
              <UserPaymStatus>unknown</UserPaymStatus>
              <AccountName>BankAmericard Cash</AccountName>
            </CardBill>
          </CardBills>
        </CardAccount>
      </CardAccounts>
      <BillingAccounts type="array">
        <BillingAccount>
          <BillingAccountId type="integer">10019359</BillingAccountId>
          <AcctType>unknown</AcctType>
          <AccountNumber>232015573049</AccountNumber>
          <AccountName>232015573049</AccountName>
          <LastPayment type="decimal">103.79</LastPayment>
          <LastPaymentDate type="date">2012-01-27</LastPaymentDate>
          <CardName>AT&amp;T</CardName>
          <Bills type="array">
            <Bill>
              <BillId type="integer">15252162</BillId>
              <BillingAccountId type="integer">10019359</BillingAccountId>
              <IsHistoric type="boolean">false</IsHistoric>
              <AcctType>unknown</AcctType>
              <MarkAsPaidReason>unknown</MarkAsPaidReason>
              <AccountNumber>232015573049</AccountNumber>
              <DerivedPaymStatus>inbox</DerivedPaymStatus>
              <EndingBalance type="decimal" nil="true"></EndingBalance>
              <PastDue type="decimal" nil="true"></PastDue>
              <AmountDue type="decimal">103.79</AmountDue>
              <MinPayment type="decimal" nil="true"></MinPayment>
              <LastPayment type="decimal" nil="true"></LastPayment>
              <IsDueDateEstimated type="boolean" nil="true"></IsDueDateEstimated>
              <PaymRecvdDate type="date" nil="true"></PaymRecvdDate>
              <BillPeriodEndDate type="date">2012-02-20</BillPeriodEndDate>
              <PaymDate type="date" nil="true"></PaymDate>
              <BillPeriodStartDate type="date">2012-01-21</BillPeriodStartDate>
              <BillDate type="date">2012-02-20</BillDate>
              <DueDate type="date">2012-03-15</DueDate>
              <LastPayDate type="date" nil="true"></LastPayDate>
              <PaymType>unknown</PaymType>
              <PaymStatus>unknown</PaymStatus>
              <IsDueOnReceipt type="boolean">false</IsDueOnReceipt>
              <UserPaymStatus>unknown</UserPaymStatus>
              <AccountName>232015573049</AccountName>
            </Bill>
          </Bills>
        </BillingAccount>
      </BillingAccounts>
    </CustomerData>
  </Customer>
  <Customer>
    <ErrorMsg>No records found for this customer</ErrorMsg>
    <CustomerDetails>
      <Email>test2@test.com</Email>
    </CustomerDetails>
  </Customer>
</Customers>
</DataServiceResponse>

=end

  def retrieve
    body = request.body.read
    if !body.blank? && hash = Nori.parse(body)['DataServiceRequest']

      dsc = hash['DataServiceConsumer']

      if dsc && consumer = authenticate(dsc) 
        begin
          req_details = hash['RequestDetails']
          data = consumer.handle_data_request(req_details) if req_details
          return render :xml => "<?xml version='1.0' encoding='UTF-8'?>\n<DataServiceResponse>\n#{data}</DataServiceResponse>"
        rescue => err
          notify_hoptoad(err)
          return render :xml => {'ErrorMsg' => 'Internal Server Error'}.to_xml(:root => "DataServiceResponse"), :status => 500
        end

      end
    end 

    return render :xml => {'ErrorMsg' => 'Data Service Consumer Not Found'}.to_xml(:root => "DataServiceResponse"), :status => 401
  end


  private

  def authenticate(dsc)
    name = dsc['Name']
    key = dsc['Key']
    DataServiceConsumer.where(:name => name).where(:key => key).first
  end
end
