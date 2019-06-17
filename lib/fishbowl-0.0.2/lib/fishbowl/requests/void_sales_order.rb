module Fishbowl::Requests
  def void_sales_order(options = {})    
    object = Fishbowl::Objects::BaseObject.new
    object.ticket = @key
    _, _, response = object.send_request('VoidSORq', 'VoidSORs', options)

  end
end
