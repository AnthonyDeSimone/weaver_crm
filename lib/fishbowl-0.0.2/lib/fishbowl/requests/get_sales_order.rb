module Fishbowl::Requests
  def get_sales_order(options = {})    
    object = Fishbowl::Objects::BaseObject.new
    object.ticket = @key
    _, _, response = object.send_request('LoadSORq', 'LoadSORs', options)

    results = []

    response.xpath("//SalesOrder").each do |xml|
      results << Fishbowl::Objects::SalesOrder.new(xml)
    end

    results
  end
end
