module Fishbowl::Requests
  def get_parts(options = {})
    object = Fishbowl::Objects::BaseObject.new
    object.ticket = @key
    _, _, response = object.send_request('GetPartListRq', 'GetPartListRs', options)
    results = []
    
    response.xpath("//LightPart").each do |xml|
      xml = Nokogiri::XML(xml.to_xml)
      results << Fishbowl::Objects::Part.new(xml)
    end

    results  
  end
end