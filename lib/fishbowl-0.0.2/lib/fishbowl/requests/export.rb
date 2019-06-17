module Fishbowl::Requests
  def export(options = {})
    object = Fishbowl::Objects::BaseObject.new
    object.ticket = @key
    
    _, _, response = object.send_request('ExportRq', 'ExportRs', options)
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