module Fishbowl::Requests
  def get_carrier_list(options = {})
    object = Fishbowl::Objects::BaseObject.new
    object.ticket = @key
    
    _, _, response = object.send_request('CarrierListRq', 'CarrierListRs', options)
    results = []

    response.xpath("//Carriers/Name").each do |carrier_xml|
      xml = Nokogiri::XML(carrier_xml.to_xml) #There might be a better way to do this
      results << Fishbowl::Objects::Carrier.new(xml)
    end

    results
  end
end


