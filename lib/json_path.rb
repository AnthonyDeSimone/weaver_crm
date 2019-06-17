class JsonPath
  def self.find(hash, path)
    path = path[1..-1]
  
    path.split("/").inject(hash) do |current, e|
      p current.class
      p e
      if(e.match(/d+/))
        e = e.to_i
      end
      p current[e]
      
      current[e]
    end
  end
end


so = JSON.load ChangeOrder.last.sales_order.json_info
co = JSON.load ChangeOrder.last.json_info

diff = JsonDiff.diff(so, co)
JsonPath.find(co, diff.first['path'])
