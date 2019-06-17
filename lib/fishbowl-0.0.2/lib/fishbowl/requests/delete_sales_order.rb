module Fishbowl::Requests
  def delete_sales_order(options = {})    
    object = Fishbowl::Objects::BaseObject.new
    object.ticket = @key
    _, _, response = object.send_request('DeleteSORq', 'DeleteSORq', options)

  end
end
