module Fishbowl::Requests
  def get_uom_list(options = {})    
    object = Fishbowl::Objects::BaseObject.new
    object.ticket = @key
    _, _, response = object.send_request('UOMRq', 'UOMRs')

    results = []
    names = response.xpath("//UOM/Name").map(&:inner_text)
    codes = response.xpath("//UOM/Code").map(&:inner_text)
    names.zip codes
  end
end
