module OptionFinder

  def self.find_component(style: , name:)
    id = style.style_keys.first.style_size_finish.key_component_pairs.
                    joins(:component).
                    where("components.name": name, "components.active": true).
                    pluck("distinct component_id")
    
    raise "error #{id.length}" if id.length != 1
    
    Component.find(id.first)
  end 

  def self.find_component_option(style: , name:, component: nil)
    if(component)
      id = style.style_keys.first.style_size_finish.key_component_pairs.
      joins(component: :component_options).
      where("components.id": component.id).
      where("component_options.name": name, "component_options.active": true).
      pluck("distinct component_options.id")
    else
      id = style.style_keys.first.style_size_finish.key_component_pairs.
                      joins(component: :component_options).
                      where("component_options.name": name, "component_options.active": true).
                      pluck("distinct component_options.id")
    end

    raise "error: #{id.length}" if id.length != 1

    ComponentOption.find(id.first)
  end 
  
end