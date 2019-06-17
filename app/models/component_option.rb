class ComponentOption < ActiveRecord::Base
  enum build_type:  [:either, :aos, :prebuilt ]
  
  belongs_to  :component

  default_scope { where(active: true).order(:sort_order, :name) }

  def form_show(size)
    hash = {name: self.name, id: self.id, price: send("#{size}_price").to_f, large_price: large_price.to_f, small_price: small_price.to_f}
    
    if(image_url && image_url != "")
      hash[:image_url] = "/image_editor/component_option/#{id}.png" #"/image_editor/" + image_url # 
    else
      hash[:image_url] = nil
    end
    
    hash[:c_height] = height
    hash[:c_width]  = width
  
    
    hash
  end
  
  def form_show2(size, show)
    hash = form_show(size)
  
    hash[:show] = true
    
    return hash
  end
end
