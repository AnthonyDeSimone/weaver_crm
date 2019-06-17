module Fishbowl::Requests
  def import(options = {})
    object = Fishbowl::Objects::BaseObject.new
    object.ticket = @key
    
    code, message, response = object.send_request('ImportRq', 'ImportRs', options)
  end
end