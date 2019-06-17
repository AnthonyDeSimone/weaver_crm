module Fishbowl::Requests
  def get_vendor_name_list(options = {})    
    object = Fishbowl::Objects::BaseObject.new
    object.ticket = @key
    _, _, response = object.send_request('VendorNameListRq', 'VendorNameListRs')

    results = []
    response.xpath("//Vendors/Name").each do |xml|
      results << xml.inner_text
    end

    results
  end
end
