module Fishbowl::Requests
  def get_import_list(options = {})
    object = Fishbowl::Objects::BaseObject.new
    object.ticket = @key
    _, _, response = object.send_request('ImportListRq', 'ImportListRs')
return response
    results = []
    #response.xpath("//Customer/Name").each do |customer_xml|
    #  results << customer_xml.inner_text
    #end

    results
  end
end
