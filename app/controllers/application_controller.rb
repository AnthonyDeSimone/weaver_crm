require 'pp'
require 'csv'
require 'dropbox'

ActiveRecord::Base.logger.level = 1

class Hash
  def diff(other)
    self.keys.inject({}) do |memo, key|
      unless self[key] == other[key]
        memo[key] = [self[key], other[key]] 
      end
      memo
    end
  end
end

class TrueClass
	def to_f
		return 1.0
	end
end

class Hash
  def to_f
    1.0
  end
end

class Object
  def yield_self
    yield self
  end

  def nil_if(&block)
    yield_self(&block) ? nil : self
  end
end

class ApplicationController < ActionController::Base
  layout 'application.html.haml'
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  skip_before_filter  :verify_authenticity_token
 # before_filter :authenticate_salesperson!, only: [:index]
	before_filter :authenticate_salesperson!, except: [:test, :styles, :features, :sizes, :prices, :doors, :preflight, :prebuilt_available, :finishable, :components, :styles_with_images, :calculate_price, ]
  before_filter :set_cache_buster

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
  
 rescue_from ActiveRecord::RecordNotFound, :with => :rescue_not_found
 
 rescue_from Exception do |exception|
  puts exception.message
  puts exception.backtrace
  rescue_server_error(exception)
 end

  def has_admin_privileges
    authenticate_salesperson!
    
    if(!['Admin', 'Delivery'].include?(current_salesperson.account_type))
      flash[:error] = 'You don\'t have access to that page.'
      redirect_to(:root)
    end
  end  
  
  def is_internal_user
    unless(['Admin', 'Internal Salesman', 'Internal Sales Manager', 'Engineering', 
        'Delivery', 'Manufacturing'].include?(current_salesperson.account_type))
      flash[:error] = 'You don\'t have access to that page.'
      redirect_to(:root)
    end  
  end
  
	def number_to_currency(number, options = {})
		ActionController::Base.helpers.number_to_currency(number, options)
	end

  def set_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

	def test
    set_headers
    response = (Style.all.map(&:name) - ['Gambrel Cabin', 'A-Frame Cabin', 'Garage', 'Dutch Barn', 'Cedar Brooke']).to_json

    render :json => response, :callback => params['callback']
	end

	def styles
    response = Style.order(:sort_order).pluck(:name).to_json

    render :json => response, :callback => params['callback']
	end

  def styles_with_images
    response = (Style.active.order(:sort_order).map{|style| {name: style.name, url: "/images/structures/#{style.name.downcase.gsub(' ', '_')}.png"}}.reject {|s| ['Leanto', 'Porch', 'Porch 12/12 Pitch'].include?(s[:name])})

    #~ response << {name: 'Timber Lodge', url: '/images/structures/timber_lodge.png'}
    response << {name: 'Custom', url: '/images/structures/custom.png'}

    render :json => response.to_json, :callback => params['callback']  
  end

  def features
    response = StyleKey.where(style: Style.where(name: params[:style])).map(&:feature).uniq.compact #(&:feature) #StructureStyleKey.where(style: params[:style]).map(&:feature).uniq.compact

    render :json => response, :callback => params['callback']
  end

	def sizes
    #style_keys = StyleKey.where(style: Style.where(name: params[:style])).order(:width, :length)
    style_keys = StyleKey.select('distinct on (length, width) *').
                          where(style: Style.where(name: params[:style])).
                          order(:width, :length)
    
    response = style_keys.map do |s| 
      {width: s.width, len: s.length, sq_feet: s.sq_feet, ln_feet: s.ln_feet}
    end 
    response = [] if(params[:style] == 'Timber Lodge' || params[:style] == 'Custom')
    
    render :json => response.uniq, :callback => params['callback']
  end

	def prices
    if(params[:style] == 'Timber Lodge' || params[:style] == 'Custom') 
      response = {base: 0}
    else
      if(params[:feature] && !params[:feature].empty? && params[:feature] != 'Custom')
        key = StyleKey.where(style: Style.where(name: params[:style]), width: params[:width], length: params[:len], feature: params[:feature]).first
      else
        key = StyleKey.where(style: Style.where(name: params[:style]), width: params[:width], length: params[:len]).first
      end

      response = JSON.load(key.zone_prices)["zone_#{params[:zone]}"][params[:build_type]] rescue 0
    end
    
    render :json => response, :callback => params['callback']
	end

	def doors
    key = StructureStyleKey.where(style: params[:style], width: params[:width], length: params[:len]).first
    response = key.door_defaults

    render :json => response, :callback => params['callback']
	end

  def prebuilt_available
    if(params[:is_custom] == 'true')
      response = true
    elsif(params[:style] == 'Timber Lodge')
      response = false
    elsif(params[:style] == 'Custom')  
      response = true
    else
      key = StyleKey.where(style: Style.where(name: params[:style]), width: params[:width], length: params[:len]).first
      response = (JSON.load(key.zone_prices)["zone_1"]['prebuilt']['base'] != 0) rescue false
    end
    
    render :json => response, :callback => params['callback']
  end

  def finishable
    if(!params[:feature] || params[:feature].empty?)
      key = StyleKey.where(style: Style.where(name: params[:style]), width: params[:width], length: params[:len]).first
    else
      key = StyleKey.where(style: Style.where(name: params[:style]), width: params[:width], length: params[:len], feature: params[:feature]).first
    end
    puts JSON.load(key.zone_prices)["zone_1"]['AOS']['stain']
    response = (JSON.load(key.zone_prices)["zone_1"]['AOS']['stain'] != 0)

    render :json => response, :callback => params['callback']
  end

  def new_components
    key = StyleKey.where(style: Style.where(name: params[:style]), width: params[:width], length: params[:len]).first
    doors = JSON.load(key.door_defaults)
    doors.map! {|d| d.gsub(/ Default (?:Wood|Double|Steel) Door/, '') } 

    if(['Gambrel Cabin', 'Cambrel Cabin', 'A-Frame Cabin', 'Garage', 'Dutch Barn', 'Cedar Brooke'].include?(params[:style]))
      size = 'large'
    else
      size = 'small'
    end

    components = ComponentCategory.all.map do |cc|
      temp = cc.component_subcategories.map do |cs|    
        style_properties = {size: size}
        style_properties[:feature] = params[:feature] if(params[:feature] && !params[:feature].empty?)
        
        components = StyleSizeFinish.where(style_properties).first.components.where(component_subcategory: cs)
                  
        {name: cs.name, components: components.select(:name){|c| c.name != 'Roof Pitch' || !key.starting_roof_pitch.nil?}.map{|c| c.form_show(key, size, {doors: doors})}} 
      end
      {name: cc.name, subsections: temp}
    end

    components.each {|cat| cat[:subsections].reject! {|subcat| subcat[:components].empty?}}
  
   render :json => components.to_json, :callback => params['callback']
  end

  def helperer(params)
    if(params[:data]['options']['style'] == 'Custom') #Custom
      categories = []
      
      subsections_1 = []
      subsections_2 = []
      subsections_3 = []
      
      ['doors', 'windows', 'porches', 'subfloor', 'wall height', 'loft', 'steps', 'roofing', 'additional options'].each do |subsection|
        subsections_1 << {:name=> subsection.capitalize, :subcategory_show=>true, 
                                                  :components=>[{ :name=>"Custom Field", :id=>0, :price=>0.0, 
                                                                  :large_price=>0.0, :small_price=>0.0, 
                                                                  :form_type=>"text", :requires_quantity=>true, 
                                                                  :pricing_type=>"each", :options=>[], 
                                                                  :value=>nil, :duplicate=>true, :image_url=>nil, 
                                                                  :show=>true}], 
                                                                  :show=>true}
      end

      { 'Exterior finishes' => ['body', 'trim', 'windows (style & color)', 'gutter', 'deck'],
        'Interior' => ['insulation', 'wall board', 'finish', 'ceilings'], 
        'Trim' => ['type', 'finish', 'baseboard', 'casing'],
        'Stairs' => ['type', 'finish', 'railing']}.each_pair do |category, components|
          component_list = components.map do |component|
            { :name=> component.capitalize, :id=>0, :price=>0.0, 
              :large_price=>0.0, :small_price=>0.0, 
              :form_type=>"text", :requires_quantity=>true, 
              :pricing_type=>"each", :options=>[], 
              :value=>nil, :duplicate=>true, :image_url=>nil, 
              :show=>true}
          end
          subsections_2 << {:name=> category, :subcategory_show=>true, 
                            :components=>component_list, 
                            :show=>true}
      end
      
      ['permits', 'utility services', 'driveway details', 'excavation', 'foundation', 'concrete work', 'well', 'septic', 'gas setup',
      'plumbing', 'electrical', 'HVAC', 'flooring', 'kitchen & vanities', 'appliances', 'closet organization'].each do |subsection|
        subsections_3 << {:name=> subsection.capitalize, :subcategory_show=>true, 
                                                  :components=>[{ :name=>"Custom Field", :id=>0, :price=>0.0, 
                                                                  :large_price=>0.0, :small_price=>0.0, 
                                                                  :form_type=>"text", :requires_quantity=>true, 
                                                                  :pricing_type=>"each", :options=>[], 
                                                                  :value=>nil, :duplicate=>true, :image_url=>nil, 
                                                                  :show=>true}], 
                                                                  :show=>true}      
      end
       
      component_hash = [{:name=>"Options I", :subsections=> subsections_1},
      component_hash =  {:name=>"Options II", :subsections=> subsections_2},
                        {:name=>"Options III", :subsections=> subsections_3}]

      #component_hash= [first]#, {name: 'Options I', subsections: subsections}, {name: 'Options 2', subsections: []}]
      return component_hash
      
               #     {name: 'Options II', subcategory_show: true, components: []}, 
                #    {name: 'Options III',subcategory_show: true, components: []}]

    elsif(params[:data]['options']['style'] == 'Timber Lodge')
      size = 'large'
      key_id = 0
      
      doors = []
    else
      if(params[:data]['options']['size']['width'])
        style_key_hash = {style: Style.where(name: params[:data]['options']['style']), 
                          width: params[:data]['options']['size']['width'], length: params[:data]['options']['size']['len']}
      else
        style_key_hash = {style: Style.where(name: params[:data]['options']['style'])}      
      end
    
      if(params[:data]['options']['feature'] && params[:data]['options']['feature'] != '' && params[:data]['options']['feature'] != 'Custom')
        style_key_hash[:feature] =  params[:data]['options']['feature']
      end
      
      if(params[:data]['options']['build_type'] && params[:data]['options']['build_type'] != '')
        integer_build_types = [Component.build_types[:either], Component.build_types[params[:data]['options']['build_type'].downcase.to_sym]]
        symbol_build_types  = ['either', params[:data]['options']['build_type'].downcase]
      else
        integer_build_types = [Component.build_types[:either], Component.build_types[:aos]]
        symbol_build_types  = ['either', 'aos']
      end

      key = StyleKey.where(style_key_hash).includes(style: {default_options: [:component, :component_option]}).first
      key_id = key.id if key

      if(key)
        doors = JSON.load(key.door_defaults)
        doors.map! {|d| d.gsub(/ Default (?:Wood|Double|Steel) Door/, '') } 
      end
      
      if(['Cambrel Cabin', 'Gambrel Cabin', 'A-Frame Cabin', 'Garage', 'Dutch Barn', 'Cedar Brooke', 'Timber Lodge'].include?(params[:data]['options']['style']))
        size = 'large'
      else 
        size = 'small'
      end
    end
    
    if(params[:data] && params[:data]['additions'] && !params[:data]['additions'].empty?)

      component_hash = params[:data]['additions']
      
      component_hash.each do |category|
      
        category['subsections'].andand.each do |subcategory|
          if(subcategory['name'] == 'Default Doors' && key)
            components = Component.joins(:component_subcategory).where("component_subcategories.name": 'Default Doors')

            currently_selected = {}
            subcategory['components'].map {|c| currently_selected[c['name']] = c['value']}

            subcategory['components'] = components.map do |c| 
              component = c.form_show2(key, size, symbol_build_types, {doors: doors, selected: currently_selected})
              component[:price] = component[:options].select {|o| o[:id] == component[:value]}.first[:price] rescue nil
              component[:small_price] = component[:price]
              component
            end
            
            next
          end
        
          subcategory_show = false
          
          #Only show roofs when the specific styles match
          subcategory['components'].andand.andand.each do |component|  
            if(component['name'] == 'Shingles' && key.style.name == 'Studio')
              component['show'] = false 
              next
            end

            if(category['name'] == 'Roof' && component['name'] == 'Roof')              
              component['options'].each do |option|
                if(option['name'].match(/Metal Roof on/))               
                  if(option['name'].include?(params[:data]['options']['style']) && !(option[:name].include?('Barn') && params[:data]['options']['style'] == 'Dutch'))
                    option['show'] = true
                  else
                    option['show'] = false
                  end
                end
              end
              
              next
            end

            if('Drop Slope Height' == component['name'])
              options['show'] = true

            #TODO: PAINT STAIN
            elsif(component['name'].match(/Pine (?:Stain|Paint) Color/) && params[:data]['options']['feature'] != 'Premier')
              component[:show] = false
            elsif(component['name'].match(/Duratemp (?:Stain|Paint) Color/) && params[:data]['options']['feature'] != 'Deluxe')
              component[:show] = false
            end    
              
            if(!(component['id']) || component['id'] < 10)
              component[:show] = true
            elsif(params[:data]['options']['style'] == 'Timber Lodge' && (component['name'] == 'Custom Field'))
              component[:show] = true
            elsif(component['name'] == "Drip Edge Color" || component['name'] == "Shingle Color")
              component[:show] = true      
            elsif(component['name'] == "Vinyl Color" && params[:data]['options']['feature'] && params[:data]['options']['feature'].match(/Vinyl/))
              component[:show] = true      
            else
              db_component = Component.unscoped.find(component['id'])

              has_key = db_component.style_size_finishes.joins(:style_keys).where("style_keys.id": key.id).any?

              if(['Wood Door Color Option', 'Wood Door Custom Color Option', 'Steel Door Color Option', 
                  'Steel Door Custom Color Option', 'OHD Color Option', 'OHD Custom Color Option', 
                  'Metal Roof Color', 'Vinyl Shutter Color', 'Vinyl Flowerbox Color',
                  'Shingle Color', 'Drip Edge Color', 'Vinyl Color'].include?(component['name']) || subcategory['name'] == 'Overhead Door Add-Ons')
                component[:show] = false

              elsif(has_key && symbol_build_types.include?(db_component.build_type) ||
                    key.nil? && component['name'] == 'Custom')
                    
                if(component['name'] == 'Roof Pitch')
                  component[:min]   = key.starting_roof_pitch 
                elsif(component['name'].andand.match(/Higher Sidewall/))
                  component[:min] = key.starting_sidewall_height
                  
                  #TODO: TEST THIS
                  # When switching feature types, use the same sidewall height as was previously picked if it exists
                  #component['value'] = subcategory['components'].select{|c| c['name'].match(/Higher Sidewall/)}.map {|c| c['value'].to_i}.max
                end 
           
                if(component['form_type'] != 'text')
                  component['price'] = component["#{size}_price"]
                end
                
                component[:show] = true
                subcategory_show = true



                if(!component['options'].nil? && !component['options'].empty?)
                  component['options'].each do |option|
                    option['price'] = option["#{size}_price"]
                  end
                end
              else
                component[:show] = false
              end                     
            end

          end
        end
      end
    else
      #doors = JSON.load(key.door_defaults)
      #doors.map! {|d| d.gsub(/ Default (?:Wood|Double|Steel) Door/, '') } 

      if(['Gambrel Cabin', 'A-Frame Cabin', 'Garage', 'Dutch Barn', 'Cedar Brooke'].include?(params[:data][:options]['style']))
        size = 'large'
      else
        size = 'small'
      end

      component_hash = ComponentCategory.includes(component_subcategories: {components: :component_options}).all.map do |cc|
        if(key.style.pavillion && ["Structural", "Paint & Stain", "Roof", "Foundation", "Cupolas"].exclude?(cc.name))
          next 
        end

        temp = cc.component_subcategories.map do |cs|   

          style_properties = {size: size}
          style_properties[:feature] = params[:data]['options']['style'] if(params[:data]['options']['style'] && !params[:data]['options']['style'].empty?)
          
          components = cs.components

          if key.style.name == 'Studio'
            components = components.where.not(name: ['Shingles', 'Shingle Color']) 
          end

          components = components.order(:order_id).map{|c| c.form_show2(key, size, symbol_build_types, {doors: doors})}

          subcategory_show = components.any? {|c| c[:show]}
          
          {name: cs.name, show: subcategory_show, components: components} 
        end
        {name: cc.name, subsections: temp}
      end
    end.compact!

    # component_hash.each do |cat| 
    #   (cat[:subsections] || cat['subsections']).each do |subcat| 
    #     subcat[:show] = !((subcat[:components] || subcat['components']).select{|c| c[:show]}).empty?
    #   end 
    # end
    
    return component_hash
  end

  def components
    set_headers
    component_hash = helperer(params)

    render :json => component_hash.to_json, :callback => params['callback']
  end
  
  def preflight
    set_headers
    render :json => [].to_json, :callback => params['callback']
  end

  def calculate_price
    set_headers
    options_subtotal  = 0
    tax_rate          = params[:data][:fees]['sales_tax'] || 7.0
    tax_rate          = 7.0 if params[:data][:fees]['sales_tax'] == ""
    delivery_cost     = params[:data][:fees]['delivery'] || 0
    discount_rate     = params[:data][:fees]['advanced']['percent'] || 0
    discount_amount   = params[:data][:fees]['advanced']['price'] || 0
    deposit           = params[:data][:fees]['deposit'] || 0
    
    sidebar_stuff = []

    if(['Timber Lodge', 'Custom'].include?(params[:data][:options]['style']))
      base = params[:data][:custom]['base_price']
    else
      if(['Gambrel Cabin', 'A-Frame Cabin', 'Garage', 'Dutch Barn', 'Cedar Brooke'].include?(params[:data][:options]['style']))
        structure_size = 'large'
      else
        structure_size = 'small'
      end

      if(params[:data][:options]['feature'] && !params[:data][:options]['feature'].empty? && params[:data][:options]['feature'] != 'Custom')
        style = Style.where(name: params[:data][:options]['style']).first
        
        if(params[:data][:options]['size']['width'])
          key = StyleKey.where(style: style, width: params[:data][:options]['size']['width'], 
                                                length: params[:data][:options]['size']['len'], feature: params[:data][:options]['feature']).first
        else
          key = StyleKey.where(style: style).first
        end
      else
        kludge_style = Style.where(name: params[:data][:options]['style']).first
        key = StyleKey.where(style: Style.where(name: params[:data][:options]['style']), width: params[:data][:options]['size']['width'], 
                                                length: params[:data][:options]['size']['len']).first
      end
      
      key ||= StyleKey.first

      zone_prices = JSON.load(key.zone_prices)
      
      if(params[:data][:options]['size'] == 'Custom')
        base = params['data']['custom']['base_price']
      else
        base = params['data']['base_price']
      end
      
      finish = (zone_prices["zone_#{params[:data][:options]['zone']}"][params[:data][:options]['build_type']][params[:data][:options]['finish']] || 0) rescue 0
    end

     if(params[:data][:options]['size'] == 'Custom')
      barn_length = params[:data]['custom']['size']['len'] 
      barn_width  = params[:data]['custom']['size']['width'] 
      barn_sq_ft  = params[:data]['custom']['size']['len']  * params[:data]['custom']['size']['width']
      barn_ln_ft  = params[:data]['custom']['size']['len']*2  + params[:data]['custom']['size']['width']*2
     else
      barn_length = key.length
      barn_width  = key.width
      barn_sq_ft  = key.sq_feet
      barn_ln_ft  = key.ln_feet
    end

    params[:data]['additions'].each do |category|
      current_sidebar_items = []
      
      category['subsections'].each do |subcategory|
        next unless subcategory['show']


        if( (subcategory['name'] == 'Paint' && params['data']['paint_stain'] != 'Paint') ||
            (subcategory['name'] == 'Stain' && params['data']['paint_stain'] != 'Stain'))
            next
        end

        subcategory['components'].andand.each do |component|
          #binding.pry if subcategory['name'] == 'Paint'

          if(!component['show'] && !(['Paint', 'Stain'].include?(subcategory['name']) && ['Paint', 'Stain'].include?(component['name'])))
            next
          end

          if(params[:data][:options]['feature'] != 'Vinyl' && [nil, ""].include?(params[:data]['paint_stain']) && 
            ['Body Color', 'Trim Color', 'Door Color', 'Shutter Color', 'Paint for AOS', 'Stain for AOS', 'Paint', 'Stain'].include?(component['name']))
            next
          end
          
          
          show_quantity     = true
          display_quantity  = nil          
          
          if((['select'].include?(component['form_type'])) && component['value'] && component['value'] != "")
            name = ComponentOption.unscoped.find(component['value'].to_i).name 
            next if name == 'None'
          end

          if((['radio'].include?(component['form_type'])) && component['value'] && component['value'] != "")
            name = ComponentOption.unscoped.find(component['value'].to_i).name 
            next if name == 'None'
          end     
          
          if(component['pricing_type'] == 'each'|| component['pricing_type'].nil?) #Pricing type is only nil with additional custom fields
            if(component['form_type'] == 'radio' && component['value'])
              quantity = effective_quantity = 1
             elsif(component['quantity'] || component['value'])
               quantity = component['quantity']
               quantity ||= component['value'] unless component['form_type'] == 'select'
                
               quantity = 1 if component['form_type'] == 'radio' 
               effective_quantity = 1
             end
          elsif(component['value'])
            case component['pricing_type']
              when 'ln_ft'
                effective_quantity = barn_ln_ft 
              when 'sq_ft'
                effective_quantity = barn_sq_ft 
              when 'len'
                effective_quantity = barn_length 
              when 'width'
                effective_quantity = barn_width 
              when 'percentage'
                effective_quantity = 1     
            end
          end

          price = component['price']
                   
          if((['radio', 'select'].include?(component['form_type'])) && component['value'] && component['value'] != "")
            name = ComponentOption.unscoped.find(component['value'].to_i).name
          elsif(component['form_type'] == 'text')            
            name = component['value']
          else
            name = component['name']
          end
          
          if(component['form_type'] == 'radio' && component['value'] && component['value'] != "")
            quantity = 1
          elsif(component['quantity'] || component['value'])
           quantity = component['quantity']
            quantity ||= component['value'] unless component['form_type'] == 'select'
           
           quantity = 1 if component['form_type'] == 'radio' 
         end        
         
         if(component['form_type'] == 'check_length' && component['value'] && component['value'] != "")
          price = component['price']
          quantity = component['len']
          effective_quantity = 1
         elsif(['check_price', 'select_price'].include?(component['form_type']) && component['value'] && component['user_price'] != 0)
          price = component['user_price']
          quantity = effective_quantity = 1
         end
         
          if(component['pricing_type'] == 'percent' && component['value'] && component['value'] != "")  
            price = base * (component['price']/100.0)
            quantity = effective_quantity = 1
          end
          
          if((['select', 'radio'].include?(component['form_type'])) && component['value'] && component['value'] != "")            
            id = component['value'].to_i
            component['options'].each do |option|
              if(option['id'] == id)
                price = option['price']
                break
              end
            end
            #price = #ComponentOption.unscoped.find(component['value']).send("#{structure_size}_price") 
          end         
          
          if(name == 'Roof Pitch' && quantity)
            if(key.style.name == 'Timber Ridge')
              display_quantity  = quantity
              quantity = quantity - key.starting_roof_pitch
            else
              display_quantity  = quantity
              quantity          = [quantity - (key.starting_roof_pitch || 5), 0].max
              

              if(quantity >= 1)
                quantity = quantity.round 
              elsif(quantity > 0)
                quantity = 1
              else
                quantity = 0
              end

              #Special Roof Pitch Handling
              if(component['id'].to_i == 929)    
                rp_component = Component.find(929)
                
                large_quantity = [(display_quantity - 8), 0].max
                small_quantity = [quantity, (8 - (key.starting_roof_pitch || 5))].min

                if(key.style.large_garage?)
                  price = ((large_quantity + small_quantity) * rp_component.small_price)
                else
                 price = (large_quantity * rp_component.large_price) + (small_quantity * rp_component.small_price)
               end 

                price = price/quantity
             end
            end
          end 

          if(name.andand.match(/Higher Sidewall/) && quantity && component[:min])
            display_quantity  = quantity
            quantity          = [quantity - key.starting_sidewall_height.to_i, 0].max
          end 

          feature = params[:data][:options]['feature']
          
          if(feature == 'Premier')
            feature_type = 'pine'
          elsif(feature == 'Deluxe')
            feature_type = 'duratemp'
          elsif(feature == 'Eco Pro')
            feature_type = 'eco_pro'            
          else
            feature_type = nil
          end
          
          if(['Paint', 'Stain','Paint for AOS', 'Stain for AOS'].include?(name))
            
            #Orders before 2/2018
            if(['Paint for AOS', 'Stain for AOS'].include?(name))
              price = SalesOrder.find(params[:data]['order_id']).aos_finish_price rescue nil
              quantity = 1
              effective_quantity = 1            
            elsif(['Paint', 'Stain'].include?(name))          
              next if (subcategory['components'].select {|c| ['Paint for AOS', 'Stain for AOS'].include?(c['name']) && c['show']}.any?)
              ps_type = [feature_type, name.downcase].compact.join('_')

              if(key.style.pavillion?)
               # binding.pry
                price = zone_prices["zone_#{params[:data][:options]['zone']}"][params[:data][:options]['build_type']]['color']       
              else
                price = zone_prices["zone_#{params[:data][:options]['zone']}"][params[:data][:options]['build_type']][ps_type] rescue 0
              end

              

              quantity = 1
              effective_quantity = 1
              show_quantity = false
            end
          end

          if(component['form_type'] == 'text' && component['requires_quantity'] == false)
            quantity = 1
          end

          if(component['form_type'] == 'select' && component['value'] && component['requires_quantity'] == false)
            quantity = 1
            effective_quantity = 1
            price = 0 unless price
          end
          
          if(component['form_type'] == 'select_price' && component['value'])
            name = "#{component['name']} - #{ComponentOption.unscoped.find(component['value'].to_i).name}" 
          end
          
          if(component['form_type'] == 'check_price' && component['value'] && component['user_price'] == 0)
            quantity = 0
          end
          
          if(['Wood Door Color Option', 'Steel Door Color Option', 'Paint Color', 'Stain Color', 'Trim Color',
              'Wood Door Custom Color Option', 'Steel Door Custom Color Option', 'OHD Color Option', 'OHD Custom Color Option',
              'Vinyl Shutter Color', 'Vinyl Flowerbox Color', 'Body Color', 'Shutter Color', 'Door Color',
              'Metal Roof Color', 'Shingle Color', 'Drip Edge Color', 'Vinyl Color', 'Drop Slope Height', 'Ceiling Color', 'Timber Color'].include?(component['name']))
            
            #Terrible kludge for the prairie/pewter color issue
            order = SalesOrder.find_by_id(params[:data][:order_id])
            if(order && order.created_at < Date.parse("2019/04/28") && component['value'].to_i == 1415) 
              name = "Pewter"
            end
            
            name = "#{component['name']} - #{name}"
            

            show_quantity = false            
          elsif([ 'Cupola Style', 'Weathervane'].include?(component['name']))
            name = "#{component['name']} - #{name}"
          elsif(component['name'] == 'Double Door Set' && name && name.size < 4)
            name = "#{name} Double Door"
          elsif(component['name'] == 'Single Door')
             name = "#{name} Single Door"        
          elsif(component['name'] == 'Extra Doors' && name && name.size < 4)
            name = "Extra #{name} Door"        
          elsif(subcategory['name'] == 'Extra Doors' && name && name.size < 4)
            name = "Extra #{name} Door"  
          elsif(name  =~ /Window Lites/)
            name = "Window Lites"
          end

          if(component['name'] == 'Brackets' || component['name'] == 'Anchoring')
            display_quantity = 0
          end 

          if(name == 'Duracolumns')
            price = zone_prices["zone_#{params[:data][:options]['zone']}"][params[:data][:options]['build_type']]['duracolumn']
          end

          if(name == 'Top of Beam Height' && quantity)
            effective_quantity = 1
            display_quantity = quantity
            quantity = (quantity - 8) * key.post_amount rescue 0
          end

          quantity = quantity.to_f          

          if(price && effective_quantity && quantity > 0)

            #Form is still sending the component when 'none' is selected. This is the work around
            next if(category['name'] == 'Windows' && subcategory['name'] == 'Windows' && component['name'] != 'Custom Field' && price == 0)
            
            if(component['final_price'] && component['final_price'] != 1 && component['form_type'] != 'text' )
              price = component['final_price'] 
            end          
          
            calculated_price = (price.to_f * quantity.to_f * effective_quantity.to_f).round(2)
            options_subtotal += calculated_price

            quantity = show_quantity ? quantity : 0
            display_quantity ||= quantity
                                    
            current_sidebar_items << {quantity: display_quantity, name: name, price: number_to_currency(calculated_price)}          
            
            if(name =~ /Door/)
              h = {quantity: display_quantity, name: name, price: number_to_currency(calculated_price)} 
            end             
          end
        end
      end

      if((style || kludge_style) && (style || kludge_style).default_options.joins(:component).where(components: {form_type: ['numeric', 'select']}).any?)
        (style || kludge_style).default_options.joins(:component).where(components: {form_type: ['numeric', 'select']}).each do |default|
          if(default.component.component_subcategory.component_category.name == category['name'])
            
            if(default.component.form_type == 'select')
              price = default.component_option.small_price
            else 
              price = default.component.small_price
            end 

            current_sidebar_items << {name: "Default #{category['name'].singularize} Credit", 
                                      price: (price * -1)}

            options_subtotal -= price
          end 
        end
      end

      sidebar_stuff << {category: category['name'], components: current_sidebar_items}
    end

    subtotal_1      = base
    subtotal_2      = base.to_i + options_subtotal
    subtotal_3      = subtotal_2 - (discount_amount + (subtotal_2 * (discount_rate/100.0))) #(subtotal_2 - discount_amount) * (1 - discount_rate/100.0)
    subtotal_4      = subtotal_3 + delivery_cost
    discount_total  = discount_amount + (subtotal_2 * (discount_rate/100.0))
    tax             = (subtotal_4 * (tax_rate / 100.0)).round(2)    
    total           = subtotal_4 + tax
    balance_due     = total - deposit

    prices 	  = {	base: number_to_currency(base), tax: number_to_currency(tax), tax_rate: tax_rate, 
                  options_subtotal: number_to_currency(options_subtotal.round(2)), 
                  subtotal_1: number_to_currency(subtotal_1),
                  subtotal_2: number_to_currency(subtotal_2),
                  subtotal_3: number_to_currency(subtotal_3),
                  subtotal_4: number_to_currency(subtotal_4),
                  total: number_to_currency(total.round(2)),
                  deposit: number_to_currency(deposit),
                  balance_due: number_to_currency(balance_due),
                  discount_total: number_to_currency(discount_total),
                  delivery: number_to_currency(delivery_cost)}

    response  = {prices: prices, sidebar_items: sidebar_stuff}

    render :json => response.to_json, :callback => params['callback']
  end
  
  def custom_components_list
    {'exterior finishes' => ['body', 'trim', 'window (style & color)', 'gutter', 'deck'],
      'interior' => ['insulation', 'wall board', 'finish', 'ceilings'],
      'trim' => ['type', 'finish', 'baseboard', 'casing'],
      'stairs' => ['type', 'finish', 'railing']}
  
  end

  def load_order
    sales_order_items = SalesOrderItem.all

    components = ComponentCategory.all.map do |cc|
      temp = cc.component_subcategories.map do |cs|
        {name: cs.name, components: cs.components.map{|c| c.form_show({line_item: quantity})}}
      end
      {name: cc.name, subsections: temp}
    end

    render :json => components.to_json, :callback => params['callback']
  end

  def save_order    
    puts "BEGINNING"
    prices = view_context.sales_order_calculator(params, :numeric)[:prices]
    puts "CALCULATED"

    site_ready_date = Date.strptime(params[:data]['extra']['site_ready_date'], "%m/%d/%Y")# rescue nil
    delivery_date = Date.strptime(params[:data]['extra']['delivery_date'], "%m/%d/%Y")# rescue nil
    
    estimated_time = params[:data]['extra']['estimated_time']
    confirmed = params[:data]['extra']['confirmed']
    
    if(confirmed)
      if(delivery_date)
        status = :scheduled
      else
        status = :live
      end    
    end
    
    outstanding_special_order = params[:data]['special_order'].select {|e| e['required'] && !e['ordered']}.size
  
    if(params[:data]['order_id'])
      SalesOrder.find.params[:data]['order_id'].update( salesperson: current_salesperson, 
                                                        customer: Customer.find(params[:data][:customer_id]), 
                                                        json_info: {data: params[:data]}.to_json, 
                                                        prices: prices.to_json, 
                                                        delivery_date: delivery_date,
                                                        site_ready_date: site_ready_date,
                                                        estimated_time: estimated_time,
                                                        confirmed: confirmed,
                                                        status: status,
                                                        crew: params[:data]['extra']['crew'],
                                                        build_type: params[:data]['options']['build_type'],
                                                        outstanding_special_order: outstanding_special_order) 
    end
    
    
    SalesOrder.create(salesperson: current_salesperson, 
                      customer: Customer.find(params[:data][:customer_id]), 
                      json_info: {data: params[:data]}.to_json, 
                      prices: prices.to_json, 
                      delivery_date: delivery_date,
                      site_ready_date: site_ready_date,
                      estimated_time: estimated_time,
                      confirmed: confirmed,
                      status: status,
                      crew: params[:data]['extra']['crew'],
                      build_type: params[:data]['options']['build_type'],
                      outstanding_special_order: outstanding_special_order)    
    
    respond_to do |format|
      format.html {render :json => {success: true}}
      format.json {render :json => {success: true}}
    end
  end
  
  def edit_components
    @categories = ComponentCategory.all  
  end

  def edit_component_images
    @categories = ComponentCategory.all  
  end
 
  def update_components
    render text: params.pretty_inspect
  end 
  
  def edit_image
    puts params
    image_url = add_to_dropbox(params['image_form']['uploaded_data'])
    
    component = Component.find(params['component_id'])
    component.image_url = image_url
    component.save
    
    render :text => image_url
  end
  
  
  protected
  def rescue_not_found
    render :template => 'not_found.html.haml', :status => :not_found
  end
  
  def rescue_server_error(exception)
    @exception = exception
    render :template => 'error.html.haml', :status => :error  
  end
   
  def add_to_dropbox(file)
    
    #This remains on my personal dropbox for now
    access_token = '4GcyA6lzV1kAAAAAAAAKewPJJwNRp-RD0-O3flBdGjCucGles3AYjySFNaKLQqcF'
    client = DropboxClient.new(access_token)

    path = "/Weaver/#{file.original_filename}"
    
    client.put_file(path, file.tempfile)
    
    session = DropboxOAuth2Session.new(access_token, nil)
    response = session.do_get "/shares/auto/#{client.format_path(path)}", {"short_url"=>false}
    url = Dropbox::parse_response(response)['url']
    
    url[0, url.size-4] + "raw=1"
  end
end
