module Fishbowl::Requests
  def get_account_list
    object = Fishbowl::Objects::BaseObject.new
    object.ticket = @key  
    _, _, response = object.send_request('GetAccountListRq', 'GetAccountListRs')

    results = []

    response.xpath("//Account").each do |account_xml|
      results << Account.new(account_xml)
    end

    results
  end
end
