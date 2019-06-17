module Fishbowl::Requests
  def get_export_list(options = {})
    object = Fishbowl::Objects::BaseObject.new
    object.ticket = @key
    
    _, _, response = object.send_request('ExportListRq', 'ExportListRs', options)
    results = []
=begin
    response.xpath("//LightPart").each do |xml|
      xml = Nokogiri::XML(xml.to_xml)
      results << Fishbowl::Objects::Part.new(xml)
    end
=end    
    response
  end
end
