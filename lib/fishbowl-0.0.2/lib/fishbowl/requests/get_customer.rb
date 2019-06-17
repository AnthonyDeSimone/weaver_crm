require 'crack'

module Fishbowl::Requests
  def get_customer(options = {})
    object = Fishbowl::Objects::BaseObject.new
    object.ticket = @key
    
    _, _, response = object.send_request('CustomerGetRq', 'CustomerGetRs', options)
    results = []

    response.xpath("//Customer").each do |xml|
      xml = Nokogiri::XML(xml.to_xml)
      results << Fishbowl::Objects::Customer.new(xml)
    end

    results
  end
end