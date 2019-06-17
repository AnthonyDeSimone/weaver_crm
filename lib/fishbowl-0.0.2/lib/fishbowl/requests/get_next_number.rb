module Fishbowl::Requests
  def get_next_number(options = {})
    object = Fishbowl::Objects::BaseObject.new
    object.ticket = @key
    _, _, response = object.send_request('GetNextNumberRq', 'GetNextNumberRs', options)
    results = []

    response.xpath("//Number").each do |xml|
      xml = Nokogiri::XML(xml.to_xml)
      results << xml.inner_text
    end

    results  
  end
end