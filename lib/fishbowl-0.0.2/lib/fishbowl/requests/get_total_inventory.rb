module Fishbowl::Requests
  def get_total_inventory(options = {})
    object = Fishbowl::Objects::BaseObject.new
    object.ticket = @key
    
    _, _, response = object.send_request('GetTotalInventoryRq', 'GetTotalInventoryRs', options)
    puts response
  end
end