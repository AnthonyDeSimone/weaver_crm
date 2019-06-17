module Fishbowl::Requests
  def print_report(options = {})
    object = Fishbowl::Objects::BaseObject.new
    object.ticket = @key
    
    code, message, response = object.send_request('PrintReportRq', 'PrintReportRs', options)
  end
end