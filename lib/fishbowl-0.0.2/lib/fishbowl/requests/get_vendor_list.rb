module Fishbowl::Requests
  def self.get_vendor_list(options = {})    
    object = Fishbowl::Objects::BaseObject.new
    object.ticket = @key
    _, _, response = Fishbowl::Objects::BaseObject.new.send_request('VendorListRq', 'VendorListRs')

    results = []
    response.xpath("//Vendor").each do |vendor_xml|
      results << Fishbowl::Objects::Vendor.new(vendor_xml)
    end

    results
  end
end
