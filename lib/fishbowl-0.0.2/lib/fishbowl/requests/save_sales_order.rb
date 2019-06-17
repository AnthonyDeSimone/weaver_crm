module Fishbowl::Requests
  def save_sales_order(options = {})    
    object = Fishbowl::Objects::BaseObject.new
    object.ticket = @key
    _, _, response = object.send_request('SOSaveRq', 'SOSaveRs', options)

    return response

    results
  end
end
