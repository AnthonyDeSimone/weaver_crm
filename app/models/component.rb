class Component < ActiveRecord::Base
  enum build_type:  [:either, :aos, :prebuilt ]
  
  has_many    :key_component_pairs
  has_many    :style_size_finishes, through: :key_component_pairs
  belongs_to  :component_subcategory
  has_many    :component_options
  
  default_scope { where(active: true) }

  accepts_nested_attributes_for :component_options

  def ordered_options
    self.component_options.order(:name)
  end

  def form_type_to_use(style_key)
    if(style_key.style.name == 'Studio' && name == 'Roof Pitch')
      return "half_numeric"
    else
      return form_type
    end
  end

  def form_show(style_key, size, opts)
    options = component_options.order(:name)
    
    if(['Roof', 'Paint', 'Stain'].include?(name))
      options = options.select(:name) {|c| !c.name.match(/(?:Metal Roof on)|(?:Paint Prebuilt)|(?:Stain Prebuilt)/) || c.name.include?(style_key.style.name)}
    end
 
    options = options.map{|o| o.form_show(size)}.sort_by {|o| o[:id]}
            
    if(opts[:doors] && name.match(/(?:Single Door)|(?:Double Door Set)/))
      selected_door = (component_options.select {|o| opts[:doors].include?(o.name[0..2])}).first rescue nil
      selected = nil

      if(selected_door)
        selected = selected_door 
        options.each {|o| o[:price] -= selected_door.send("#{size}_price")}
      end
      
    elsif(name == 'Shingles')
      selected = ComponentOption.find_by_name('25 Year Shingles')
    end
    
    hash = {name: name, id: id, price: send("#{size}_price").to_f, large_price: large_price.to_f, small_price: small_price.to_f, 
            form_type: form_type_to_use(style_key), requires_quantity: requires_quantity,
            pricing_type: pricing_type, options: options, value: (selected.id rescue nil)}

    if(name == 'Roof Pitch')
      return nil if style_key.starting_roof_pitch.nil?
      hash[:max] = 12
      hash[:min] = style_key.starting_roof_pitch
    end
    
    if(form_type == 'text')
      hash[:duplicate] = (name == 'Custom Field')
    end
    
    if(image_url && image_url != "")
      hash[:image_url] =  "/image_editor/component/#{id}.png" #"/image_editor/" + image_url #
    else
      hash[:image_url] = nil
      hash[:c_height] = height
      hash[:c_width] = width
    end
    
    hash[:options] ||= []
    
    return hash
  end
  
  def form_show2(style_key, size, build_types, opts)
    has_key = StyleKey.includes(:style_size_finish).where(style_size_finish: style_size_finishes).where("style_keys.id": style_key.id).any?
    show = (has_key && build_types.include?(self.build_type)) || (style_key.nil? && self.name == 'Custom Field')
    
    if(['Wood Door Color Option', 'Wood Door Custom Color Option', 'Steel Door Color Option', 
        'Steel Door Custom Color Option', 'OHD Color Option', 'OHD Custom Color Option', 'Shutter Color'].include?(name) || self.component_subcategory['name'] == 'Overhead Door Add-Ons')
      show = false
    elsif('Metal Roof Color' == name && style_key.style.name != "Studio")
      show = false
    end
    
    if(name.match(/color/i))
      options = component_options.map{|o| o.form_show2(size, show)}
    else
      options = component_options.map{|o| o.form_show2(size, show)}
    end

    if(name.match(/Pine (?:Stain|Paint) Color/) && style_key.feature != 'Premier')
      show = false
    elsif(name.match(/Duratemp (?:Stain|Paint) Color/) && style_key.feature != 'Deluxe')
      show = false
    end
            
    if(name.match(/(?:Single Door)|(?:Double Door Set)/) && opts[:doors])
      selected = ComponentOption.unscoped.find(opts[:selected][name]) rescue nil

      default_door = (component_options.select {|o| opts[:doors].include?(o.name)}).first rescue nil
      selected ||= default_door
      
      #selected = nil

      if(default_door) 
        options.each do |o|
          o[:price] -= default_door.send("#{size}_price")
          o[:large_price] -= default_door.send("large_price")
          o[:small_price] -= default_door.send("small_price")
        end
        
      end
      
    elsif(name == 'Shingles')
      selected = ComponentOption.find_by_name('25 Year Shingles')
    end
    
    hash = {name: name, id: id, price: send("#{size}_price").to_f, large_price: large_price.to_f, small_price: small_price.to_f,
            form_type: form_type_to_use(style_key), requires_quantity: requires_quantity,
            pricing_type: pricing_type, options: options, value: (selected.id rescue nil)}

    if(name == 'Roof Pitch')
      if style_key.starting_roof_pitch.present?
        starting_pitch = style_key.starting_roof_pitch

        hash[:max] = 12
        hash[:min] = (starting_pitch % 1 == 0) ? starting_pitch.to_i : starting_pitch
      else
        hash[:max] = 12
        show = false     
      end
    elsif(name == 'Top of Beam Height')
      if style_key.beam_height.present?
        hash[:max] = 10
        hash[:min] = style_key.beam_height
      else
        hash[:max] = 10
        show = false     
      end
    end
    # Deal with non-door default options
    if(default_option = style_key.style.default_options.find_by(component: self))
      puts "HAS A DEFAULT"
      puts name
      if(self.component_options.any?)
        selected = default_option.component_option

        if(form_type != 'select')
          hash[:options].each do |option|
            if(selected.send("#{size}_price"))
              option[:price] -= selected.send("#{size}_price")
            end
          end
        end

        hash[:value]    = selected.id
        hash[:quantity]  = 1
      else 
        hash[:value] = 1
      end
    end

    if(name == 'Roof')

      hash[:options].each do |option|
        if(option[:name].match(/Metal Roof on/))          
          if(option[:name].include?(style_key.style.name) && !(option[:name].include?('Barn') && style_key.style.name == 'Dutch'))
            option[:show] = true
          else
            option[:show] = false
          end
        end  
      end 
    end


    if(name.match(/Higher Sidewall/))
      unless style_key.andand.starting_sidewall_height.nil?
        hash[:min] = style_key.starting_sidewall_height
      end
    end
    
    if(form_type == 'text')
      hash[:duplicate] = (name == 'Custom Field')
    end
    
    if(image_url && image_url != "")
      hash[:image_url] = "image_editor/component/#{id}.png" #"/image_editor/" + image_url #
      hash[:i_height] = self.height
      hash[:i_width] = self.width      
    else
      hash[:image_url] = nil
    end


    hash[:show] = show
    hash[:options] ||= []
    return hash
  end
end
