module ApplicationHelper
  include ActionView::Helpers::NumberHelper
  
  PAGE_ICONS = {'Customers' => 'user-2', 'Sales Orders' => 'drawer-2', 'Users' => 'user-3', 'Sales Order Map' => 'grid-view', 'Fishbowl Settings' => 'cog',
                'Service Tickets' => 'flag-2' , 'Opportunities' => 'fire', 'Sales Teams' => 'support', 'Reports' => 'attachment'}

  def has_production_access
    current_salesperson.can_download_production_copy
  end
  
  def calculate_revisions(arr1, arr2)
    differences = []
      
    arr1.each_with_index do |h, i|
      puts h.class    
      puts h.inspect
      
      difference = h.diff(arr2[i])[:components]
      next unless difference
      
      starting = (difference.first - difference.last)
      ending = (difference.last - difference.first)

      starting.each do |s|
        found = nil
        
        ending.each do |e|
          if(s[:id] == e[:id])
            found = e
            break
          end
        end
        
        if(found)
          original_quantity = s[:quantity]
          s[:quantity] = found[:quantity] - s[:quantity]
         # s[:price] = "$#{((s[:price].gsub(/[$,]/,'').to_f / original_quantity) * s[:quantity]).abs}"
          differences << s
        else
          s[:quantity] *= -1
          differences << s
        end
      end
      
      ending.each do |e|
        found = nil
        
        starting.each do |s|
          if(s[:id] == e[:id])
            found = e
            break
          end
        end
        
        if(!found)
          differences << e
        end
      end
    end  
    return differences
  end

  def breadcrumbs(pages)
    if(pages.nil?)
    Haml::Engine.new("%ul.breadcrumb
  %li
    %a{:href => 'index'}
      %i.radmin-icon.radmin-home
      Dashboard
    %span.divider /
  %li.active").render    
    elsif(pages.size == 1)
    Haml::Engine.new("%ul.breadcrumb
  %li
    %a{:href => 'index'}
      %i.radmin-icon.radmin-home
      Dashboard
    %span.divider /
  %li.active
    %i.radmin-#{PAGE_ICONS.fetch(pages[0], 'file')}
    #{pages[0]}").render
    elsif(pages.size == 2)
    Haml::Engine.new("%ul.breadcrumb
  %li
    %a{:href => '/index'}
      %i.radmin-icon.radmin-home
      Dashboard
    %span.divider /
  %li
    %a{:href => '/#{pages[0].parameterize.underscore}'}
      %i.radmin-#{PAGE_ICONS.fetch(pages[0], 'file')}
      #{pages[0]}
    %span.divider /
  %li.active
    %i.radmin-#{PAGE_ICONS.fetch(pages[1], 'file')}
    #{pages[1]}").render    
    end
  end


  def flash_class(level)
    case level.to_sym
      when :notice then "alert alert-info"
      when :success then "alert alert-success"
      when :error then "alert alert-error"
      when :alert then "alert alert-error"
      else "alert alert-info"
    end
  end

  def add_order_markers(orders)
    js = "var infowindows = [];
          function close_popups(){
            for(var i = 0; i<infowindows.length; i++){
              infowindows[i].close();
            }
          }"
    
    orders.each_with_index do |order, i|
      next unless order.customer
      next if (order.customer.latitude.nil? || order.customer.latitude == "")
      
      if(order.change_orders.size > 0)        
        json = JSON.load(order.change_orders.order(:id).last.json_info)
      else
        json = JSON.load(order.json_info)
      end   
      
      if(json['data']['options']['size'] == 'Custom')
        width   = json['data']['custom']['size']['width']
        length  = json['data']['custom']['size']['len']
      else
        width = json['data']['options']['size']['width']
        length = json['data']['options']['size']['len']
      end
      
      errors = (json['data']['warnings'].andand.values.andand.flatten || []) + (order.special_order_warnings || []) 
      
      js += " bounds = new google.maps.LatLngBounds();
              var contentString_#{order.id} = '<div id=\"info_#{order.id}\" style=\"width: 400px;\">'+    
                                  '<h3 id=\"firstHeading\" class=\"firstHeading\">'+
                                  '#{order.id} - #{width} x #{length} #{json['data']['options']['style']}  #{json['data']['options']['feature']}</h1><hr>'+
                                  '<div id=\"bodyContent\">'+
                                  '<p>#{order.customer.andand.name.gsub(/'/, "\\\\'")} #{order.customer.primary_phone}</p>'+
                                  '#{"<p>#{json['data']['serial_number']}</p>" if json['data']['serial_number']}'+
                                  '<p><b>Validation:</b> #{errors.empty? ? 'Clear' : errors.join('<br>').gsub(/'/, "\\\\'")}</p>'+
                                  '<p>#{json['data']['site_ready_date']}</p>'+                                  
                                  '<p><a href=\"/sales_orders/#{order.id}/edit\">Open Order</a></p>'+
                                  '<p>Notes: #{h(order.notes).gsub("\n", "<br>").gsub(/'/, "\\\\'")}</p>'+
                                  '<p>Site #{'Not ' unless order.site_ready}Ready</p>'+                          
                                  '<p>#{json['data']['customer']['shipping']['address'].gsub(/'/, "\\\\'")} #{json['data']['customer']['shipping']['city'].gsub(/'/, "\\\\'")} #{json['data']['customer']['shipping']['state']} #{json['data']['customer']['shipping']['zip']}}</p>'+                          
                                  '</div>'+
                                  '</div>';
      
      var infowindow_#{order.id} = new google.maps.InfoWindow({
        content: contentString_#{order.id}
      })
      
      infowindows.push(infowindow_#{order.id});
      
      var marker = new google.maps.Marker({
          position: new google.maps.LatLng(#{order.latitude}, #{order.longitude}), 
          map: map,
          icon: '/img/pins/#{order.get_pin}.png'
      })
  
      google.maps.event.addListener(marker, 'click', function(){
        close_popups();
        infowindow_#{order.id}.open(map, this)
      })\n"   
      end   
  
    return js
  end
  
  def add_service_markers(tickets)
    js = "var infowindows = [];
          function close_popups(){
            for(var i = 0; i<infowindows.length; i++){
              infowindows[i].close();
            }
          }"
          
    tickets.each_with_index do |ticket, i|
      next unless ticket.customer      
      next if (ticket.latitude.nil? || ticket.latitude == "")
      
      js += " bounds = new google.maps.LatLngBounds();
              var contentString_#{ticket.id} = '<div id=\"info_#{ticket.id}\" style=\"width: 400px;\">'+    
                                  '<h3 id=\"firstHeading\" class=\"firstHeading\">'+
                                  'Service Ticket #{ticket.id}</h3><hr>'+
                                  '<div id=\"bodyContent\">'+
                                  '<p>#{ticket.customer.andand.name.gsub(/'/, "\\\\'")}</p>'+                                   
                                  '<p>Details: #{h(ticket.notes).gsub("\n", '<br>').gsub(/'/, "\\\\'")}</p>'+                                                 
                                  '<p>#{ticket.customer.address.gsub(/'/, "\\\\'")} #{ticket.customer.city.gsub(/'/, "\\\\'")} #{ticket.customer.state} #{ticket.customer.zip}</p>'+                         
                                  '</div>'+
                                  '</div>';
                                  
      var infowindow_#{ticket.id} = new google.maps.InfoWindow({
        content: contentString_#{ticket.id}
      })
      
      infowindows.push(infowindow_#{ticket.id});
      
      var marker = new google.maps.Marker({
          position: new google.maps.LatLng(#{ticket.latitude}, #{ticket.longitude}), 
          map: map,
          icon: '/img/pins/#{ticket.pin_path}'
      })
  
      google.maps.event.addListener(marker, 'click', function(){
        close_popups();
        infowindow_#{ticket.id}.open(map, this)
      })\n"       
    end

    return js
  end  
  
  def sales_order_calculator(params, format, show_custom_field_names = false, force_paint_stain=false)

    style = Style.find_by_name(params['data']['options']['style'])

    options_subtotal  = 0
    tax_rate          = params['data']['fees']['sales_tax'] || 7.0
    delivery_cost     = params['data']['fees']['delivery'] || 0
    discount_rate     = params['data']['fees']['advanced']['percent'] || 0
    discount_amount   = params['data']['fees']['advanced']['price'] || 0
    
    sidebar_stuff = []

    if(['Timber Lodge', 'Custom'].include?(params['data']['options']['style']))
      base = params['data']['custom']['base_price']
    else
      if(['Gambrel Cabin', 'A-Frame Cabin', 'Garage', 'Dutch Barn', 'Cedar Brooke'].include?(params['data']['options']['style']))
        structure_size = 'large'
      else
        structure_size = 'small'
      end

      if(params['data']['options']['feature'] && !params['data']['options']['feature'].empty?  && params['data']['options']['feature'] != 'Custom')
        style = Style.where(name: params['data']['options']['style']).first
        
        if(params['data']['options']['size']['width'])
          key = StyleKey.where(style: style, width: params['data']['options']['size']['width'], 
                                length: params['data']['options']['size']['len'], feature: params['data']['options']['feature']).first
        else
          key = StyleKey.where(style: style).first    
        end
      else
        key = StyleKey.where(style: Style.where(name: params['data']['options']['style']), width: params['data']['options']['size']['width'], 
                                                length: params['data']['options']['size']['len']).first
      end

      key ||= StyleKey.first
      
      zone_prices = JSON.load(key.zone_prices)
      
      finish = (zone_prices["zone_#{params['data']['options']['zone']}"][params['data']['options']['build_type']][params['data']['options']['finish']] || 0) rescue 0

    end 
    
     if(params['data']['options']['size'] == 'Custom')
      base = params['data']['custom']['base_price']
            
      barn_length = params['data']['custom']['size']['len'] 
      barn_width  = params['data']['custom']['size']['width'] 
      barn_sq_ft  = params['data']['custom']['size']['len']  * params['data']['custom']['size']['width']
      barn_ln_ft  = params['data']['custom']['size']['len']*2  + params['data']['custom']['size']['width']*2
    else
      base = params['data']['base_price']  
      
      barn_length = key.length
      barn_width  = key.width
      barn_sq_ft  = key.sq_feet
      barn_ln_ft  = key.ln_feet
    end
       
    params['data']['additions'].andand.each do |category|
      current_sidebar_items = []

      category['subsections'].each do |subcategory|
        next unless (subcategory['show'] || subcategory[:show])


        if( (subcategory['name'] == 'Paint' && params['data']['paint_stain'] != 'Paint') ||
            (subcategory['name'] == 'Stain' && params['data']['paint_stain'] != 'Stain'))
            next
        end

        subcategory['components'].andand.each do |component|
          component = component.with_indifferent_access

          if(!component['show'] && !(['Paint', 'Stain'].include?(subcategory['name']) && ['Paint', 'Stain'].include?(component['name'])))
            next
          end

     
          if(params['data']['options']['feature'] != 'Vinyl' && [nil, ""].include?(params['data']['paint_stain']) && 
            ['Body Color', 'Trim Color', 'Door Color', 'Shutter Color', 'Paint for AOS', 'Stain for AOS', 'Paint', 'Stain'].include?(component['name']))
            next
          end
                            
          description       = nil
          show_quantity     = true
          display_quantity  = nil
          
          if((['select'].include?(component['form_type'])) && component['value'])
            name = ComponentOption.unscoped.find(component['value'].to_i).name 
            
            next if name == 'None'
          end

          if((['radio'].include?(component['form_type'])) && component['value'])
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
                   
          if((['radio', 'select'].include?(component['form_type'])) && component['value'])
            name = ComponentOption.unscoped.find(component['value'].to_i).name
          elsif(component['form_type'] == 'text')       
            if(show_custom_field_names)
              name = component['name']
              description = component['value']
            else
              name = component['value']
            end
          else
            name = component['name']
          end
          
          if(component['form_type'] == 'radio' && component['value'])
            quantity = 1
          elsif(component['quantity'] || component['value'])
           quantity = component['quantity']
            quantity ||= component['value'] unless component['form_type'] == 'select'
           
           quantity = 1 if component['form_type'] == 'radio' 
         end        
         
         if(component['form_type'] == 'check_length' && component['value'])
          price = component['price']
          quantity = component['len']
          effective_quantity = 1
         elsif(component['form_type'] == 'check_price' && component['value'] && component['user_price'] != 0)
          price = component['user_price']
          quantity = effective_quantity = 1
         end
         
          if(component['pricing_type'] == 'percent' && component['value'])  
            price = base * (component['price']/100.0)
            quantity = effective_quantity = 1
          end
          
          if((['select', 'radio'].include?(component['form_type'])) && component['value'])            
            id = component['value'].to_i
            component['options'].each do |option|
              if(option['id'] == id)
                price = option['price']
                break
              end
            end
          end         
          
          if(name == 'Roof Pitch' && quantity)
            display_quantity  = quantity
            quantity          = [quantity - (key.starting_roof_pitch || 5), 0].max

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
          
          if(name.andand.match(/Higher Sidewall/) && quantity && component['min'])
            display_quantity  = quantity
            quantity          = [quantity - key.starting_sidewall_height.to_i, 0].max
          end           

          if(component['form_type'] == 'select_price' && component['value'])
            name = "#{component['name']} - #{ComponentOption.unscoped.find(component['value'].to_i).name}"
            price = component['user_price']
            quantity = 1
            effective_quantity = 1
          end
          
          feature = params['data']['options']['feature']
          
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
              price = SalesOrder.find(params['data']['order_id']).aos_finish_price rescue nil
              quantity = 1
              effective_quantity = 1
            elsif(['Paint', 'Stain'].include?(name))

              next if (subcategory['components'].select {|c| ['Paint for AOS', 'Stain for AOS'].include?(c['name']) && c['show']}.any?)
              ps_type = [feature_type, name.downcase].compact.join('_')

              if(key.style.pavillion?)
                price = zone_prices["zone_#{params['data']['options']['zone']}"][params['data']['options']['build_type']]['color']       
              else
                price = zone_prices["zone_#{params['data']['options']['zone']}"][params['data']['options']['build_type']][ps_type] rescue 0
              end

              quantity = 1
              effective_quantity = 1
              show_quantity = false
            end
              

            

              #PRICE COMPARISON HACK
              if(params['data']['paint_stain'] && (name == params['data']['paint_stain']) && force_paint_stain)
                effective_quantity = 1
                quantity = 1
                ps_type = [feature_type, name.downcase].compact.join('_')

                price = zone_prices["zone_#{params['data']['options']['zone']}"][params['data']['options']['build_type']][ps_type] rescue 0
  
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
          
          if(component['form_type'] == 'check_price' && component['value'] && component['user_price'] == 0)
            price = component['user_price']
            quantity = 0
          end
          
          if(['Wood Door Color Option', 'Steel Door Color Option', 'Paint Color', 'Stain Color', 'Trim Color',
              'Wood Door Custom Color Option', 'Steel Door Custom Color Option', 'OHD Color Option', 'OHD Custom Color Option',
              'Metal Roof Color', 'Vinyl Shutter Color', 'Vinyl Flowerbox Color', 'Door Color', 'Shutter Color',
              'Shingle Color', 'Drip Edge Color', 'Vinyl Color', 'Drop Slope Height', 'Ceiling Color', 'Timber Color'].include?(component['name']))
            
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
            price = zone_prices["zone_#{params['data']['options']['zone']}"][params['data']['options']['build_type']]['duracolumn']
          end

          if(name == 'Top of Beam Height' && quantity)
            effective_quantity = 1
            display_quantity = quantity
            quantity = (quantity - 8) * key.post_amount rescue 0
          end          
                    
          quantity = quantity.to_f
          
          if(price && effective_quantity && quantity != 0  || (show_custom_field_names && component['form_type'] == 'text'))
            next if(category['name'] == 'Windows' && subcategory['name'] == 'Windows' && component['name'] != 'Custom Field' && price == 0)

            if(component['final_price'] && component['final_price'] != 1 && component['form_type'] != 'text' )
              price = component['final_price'] 
            end
            
            calculated_price = (price.to_f * quantity.to_f * effective_quantity.to_f).round(2)
            options_subtotal += calculated_price

            quantity = show_quantity ? quantity : 0
            display_quantity ||= quantity
            
            current_sidebar_items << {quantity: display_quantity, name: name, unit_price: number_to_currency(price), 
                                      price: number_to_currency(calculated_price), id: component['id'], 
                                      subcategory: subcategory['name'], description: description, form_type: component['form_type']}       
                                      
          end
        end
      end
      sidebar_stuff << {category: category['name'], components: current_sidebar_items}
    end

    subtotal  = ((base.to_i + options_subtotal + delivery_cost) - discount_amount) * (1 - discount_rate/100.0)
    tax       = (subtotal * (tax_rate / 100.0)).round(2)
    total     = subtotal + tax

    options_subtotal  = number_to_currency(options_subtotal.round(2)) if format == :money
    total             = number_to_currency(total.round(2))            if format == :money
    tax               = number_to_currency(tax.round(2))              if format == :money
    base              = number_to_currency(base.to_i.round(2))        if format == :money
   # finish            = number_to_currency(finish.round(2))           if format == :money
  

    prices 	  = {	base: base, tax: tax, tax_rate: tax_rate, finish: finish, 
                  options_subtotal: options_subtotal, total: total}

    response  = {prices: prices, sidebar_items: sidebar_stuff}  
    
    return response
  end  
 
  def revision_calculator(params, show_custom_field_names = false)
      sidebar_stuff = []
    
      params['data']['additions'].each do |category|
      current_sidebar_items = []
      
      category['subsections'].each do |subcategory|
        next unless subcategory['show']
        
        subcategory['components'].andand.each do |component|
          description = nil
          show_quantity = true
          next unless component['show']
          
          if((['select'].include?(component['form_type'])) && component['value'])
            name = ComponentOption.unscoped.find(component['value'].to_i).name 
            
            next if name == 'None'
          end

          if((['radio'].include?(component['form_type'])) && component['value'])
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
                   
          if((['radio', 'select'].include?(component['form_type'])) && component['value'])
            name = ComponentOption.unscoped.find(component['value'].to_i).name
          elsif(component['form_type'] == 'text')       
            if(show_custom_field_names)
              name = component['name']
              description = component['value']
            else
              name = component['value']
            end
          else
            name = component['name']
          end
          
          if(component['form_type'] == 'radio' && component['value'])
            quantity = 1
          elsif(component['quantity'] || component['value'])
           quantity = component['quantity']
            quantity ||= component['value'] unless component['form_type'] == 'select'
           
           quantity = 1 if component['form_type'] == 'radio' 
         end        
         
         if(component['form_type'] == 'check_length' && component['value'])
          price = component['price']
          quantity = component['len']
          effective_quantity = 1
         elsif(component['form_type'] == 'check_price' && component['value'] && component['user_price'] != 0)
          price = component['user_price']
          quantity = effective_quantity = 1
         end
         
          if(component['pricing_type'] == 'percent' && component['value'])  
            price = base * (component['price']/100.0)

            quantity = effective_quantity = 1
          end
          
          if((['select', 'radio'].include?(component['form_type'])) && component['value'])            
            id = component['value'].to_i
            component['options'].each do |option|
              if(option['id'] == id)
                price = option['price']
                break
              end
            end
          end         
          
          if(name == 'Roof Pitch' && quantity)
            quantity = [quantity - key.starting_roof_pitch, 0].max
            name = 'Additional Roof Pitch'
          end 

          if(name.andand.match(/Higher Sidewall/) && quantity && component['min'])
            display_quantity  = quantity
            quantity          = [quantity - key.starting_sidewall_height.to_i, 0].max
          end     
          
          if(component['form_type'] == 'select_price' && component['value'])
            name = "#{component['name']} - #{ComponentOption.unscoped.find(component['value'].to_i).name}"
          end
          
          if(name == 'Paint for AOS')
            price = zone_prices["zone_#{params['data']['options']['zone']}"][params['data']['options']['build_type']]['paint']
          elsif(name == 'Stain for AOS')
            price = zone_prices["zone_#{params['data']['options']['zone']}"][params['data']['options']['build_type']]['stain']          
          end
                    
          if(component['form_type'] == 'text' && component['requires_quantity'] == false)
            quantity = 1
          end

          if(component['form_type'] == 'select' && component['value'] && component['requires_quantity'] == false)
            quantity = 1
            effective_quantity = 1
            price = 0 unless price
          end
          
          if(component['form_type'] == 'check_price' && component['value'] && component['user_price'] == 0)
            quantity = 0
            price = component['user_price']
          end
          
          if(['Wood Door Color Option', 'Steel Door Color Option', 'Paint Color', 'Stain Color', 'Trim Color',
              'Wood Door Custom Color Option', 'Steel Door Custom Color Option', 'OHD Color Option', 'OHD Custom Color Option',
              'Metal Roof Color', 'Vinyl Shutter Color', 'Vinyl Flowerbox Color', 'Body Color', 'Shutter Color', 'Door Color',
              'Shingle Color', 'Drip Edge Color', 'Vinyl Color', 'Drop Slope Height', 'Ceiling Color', 'Timber Color'].include?(component['name']))
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
                    
          quantity = quantity.to_f

         
          
          if(price && effective_quantity && quantity > 0 )
            if(component['final_price'] && component['final_price'] != 1 && component['form_type'] != 'text' )
              price = component['final_price'] 
            end
            
            calculated_price = (price.to_f * quantity.to_f * effective_quantity.to_f).round(2)

            quantity = show_quantity ? quantity : 0
                        
            current_sidebar_items << {quantity: quantity, name: name, unit_price: number_to_currency(price), 
                                      price: number_to_currency(calculated_price), id: component['id'], 
                                      subcategory: subcategory['name'], description: description, form_type: component['form_type']}          
          end
        end
      end
      sidebar_stuff << {category: category['name'], components: current_sidebar_items}
    end
    
    return [sidebar_stuff, sidebar_stuff.map {|e| e['components']}.flatten.compact]
  end    
  
  def sales_order_recalculate(params)
    show_custom_field_names = false
    
    style = Style.find_by_name(params['data']['options']['style'])

    options_subtotal  = 0
    tax_rate          = params['data']['fees']['sales_tax'] || 7.0
    delivery_cost     = params['data']['fees']['delivery'] || 0
    discount_rate     = params['data']['fees']['advanced']['percent'] || 0
    discount_amount   = params['data']['fees']['advanced']['price'] || 0
    deposit           = params['data']['fees']['deposit'] || 0
    
    sidebar_stuff = []

    if(['Timber Lodge', 'Custom'].include?(params['data']['options']['style']))
      base = params['data']['custom']['base_price']
    else
      if(['Gambrel Cabin', 'A-Frame Cabin', 'Garage', 'Dutch Barn', 'Cedar Brooke'].include?(params['data']['options']['style']))
        structure_size = 'large'
      else
        structure_size = 'small'
      end

      if(params['data']['options']['feature'] && !params['data']['options']['feature'].empty?  && params['data']['options']['feature'] != 'Custom')
        style = Style.where(name: params['data']['options']['style']).first

        if(params['data']['options']['size']['width'])
          key = StyleKey.where(style: style, width: params['data']['options']['size']['width'], 
                                length: params['data']['options']['size']['len'], feature: params['data']['options']['feature']).first
        else
          key = StyleKey.where(style: style).first    
        end
      else
        key = StyleKey.where(style: Style.where(name: params['data']['options']['style']), width: params['data']['options']['size']['width'], 
                                                length: params['data']['options']['size']['len']).first
      end

      zone_prices = JSON.load(key.zone_prices) rescue 0
      
      if(params['data']['options']['size'] == 'Custom')
        base = params['data']['custom']['base_price']  
      else
        base = params['data']['base_price']
      end
      
      finish = (zone_prices["zone_#{params['data']['options']['zone']}"][params['data']['options']['build_type']][params['data']['options']['finish']] || 0) rescue 0
    end
    
     if(params['data']['options']['size'] == 'Custom')
      barn_length = params['data']['custom']['size']['len'] 
      barn_width  = params['data']['custom']['size']['width'] 
      barn_sq_ft  = params['data']['custom']['size']['len']  * params['data']['custom']['size']['width']
      barn_ln_ft  = params['data']['custom']['size']['len']*2  + params['data']['custom']['size']['width']*2
    else
      barn_length = key.length
      barn_width  = key.width
      barn_sq_ft  = key.sq_feet
      barn_ln_ft  = key.ln_feet
    end    
    
    params['data']['additions'].each do |category|
      current_sidebar_items = []
      
      category['subsections'].each do |subcategory|
        next unless subcategory['show']
        
        subcategory['components'].andand.each do |component|
          description = nil
          show_quantity = true
          next unless component['show']
          
          if((['select'].include?(component['form_type'])) && component['value'])
            name = ComponentOption.unscoped.find(component['value'].to_i).name 
            
            next if name == 'None'
          end

          if((['radio'].include?(component['form_type'])) && component['value'])
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
                   
          if((['radio', 'select'].include?(component['form_type'])) && component['value'])
            name = ComponentOption.unscoped.find(component['value'].to_i).name
          elsif(component['form_type'] == 'text')       
            if(show_custom_field_names)
              name = component['name']
              description = component['value']
            else
              name = component['value']
            end
          else
            name = component['name']
          end
          
          if(component['form_type'] == 'radio' && component['value'])
            quantity = 1
          elsif(component['quantity'] || component['value'])
           quantity = component['quantity']
            quantity ||= component['value'] unless component['form_type'] == 'select'
           
           quantity = 1 if component['form_type'] == 'radio' 
         end        
         
         if(component['form_type'] == 'check_length' && component['value'])
          price = component['price']
          quantity = component['len']
          effective_quantity = 1
         elsif(component['form_type'] == 'check_price' && component['value'] && component['user_price'] != 0)
          price = component['user_price']
          quantity = effective_quantity = 1
         end
         
          if(component['pricing_type'] == 'percent' && component['value'])  
            price = base * (component['price']/100.0)
            quantity = effective_quantity = 1
          end
          
          if((['select', 'radio'].include?(component['form_type'])) && component['value'])            
            id = component['value'].to_i
            component['options'].each do |option|
              if(option['id'] == id)
                price = option['price']
                break
              end
            end
          end         
          
          if(name == 'Roof Pitch' && quantity)
            quantity = [quantity - key.starting_roof_pitch, 0].max
            name = 'Additional Roof Pitch'
          end 

          if(component['form_type'] == 'select_price' && component['value'])
            name = "#{component['name']} - #{ComponentOption.unscoped.find(component['value'].to_i).name}"
          end
          
          if(name == 'Paint for AOS')
            price = zone_prices["zone_#{params['data']['options']['zone']}"][params['data']['options']['build_type']]['paint']
          elsif(name == 'Stain for AOS')
            price = zone_prices["zone_#{params['data']['options']['zone']}"][params['data']['options']['build_type']]['stain']          
          end
                    
          if(component['form_type'] == 'text' && component['requires_quantity'] == false)
            quantity = 1
          end

          if(component['form_type'] == 'select' && component['value'] && component['requires_quantity'] == false)
            quantity = 1
            effective_quantity = 1
            price = 0 unless price
          end
          
          if(component['form_type'] == 'check_price' && component['value'] && component['user_price'] == 0)
            price = component['user_price'] 
            quantity = 0
          end
          
          if(['Wood Door Color Option', 'Steel Door Color Option', 'Paint Color', 'Stain Color', 'Trim Color',
              'Wood Door Custom Color Option', 'Steel Door Custom Color Option', 'OHD Color Option', 'OHD Custom Color Option',
              'Metal Roof Color', 'Vinyl Shutter Color', 'Vinyl Flowerbox Color', 'Timber Color',
              'Shingle Color', 'Drip Edge Color', 'Vinyl Color', 'Drop Slope Height', 'Ceiling Color'].include?(component['name']))
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
                    
          quantity = quantity.to_f
          
          if(price && effective_quantity && quantity > 0 || (show_custom_field_names && component['form_type'] == 'text'))
            if(component['final_price'] && component['final_price'] != 1 && component['form_type'] != 'text')
              price = component['final_price'] 
            end
            
            calculated_price = (price.to_f * quantity.to_f * effective_quantity.to_f).round(2)
            options_subtotal += calculated_price

            quantity = show_quantity ? quantity : 0
                        
            current_sidebar_items << {quantity: quantity, name: name, unit_price: number_to_currency(price), 
                                      price: number_to_currency(calculated_price), id: component['id'], 
                                      subcategory: subcategory['name'], description: description}          
          end
        end
      end
      sidebar_stuff << {category: category['name'], components: current_sidebar_items}
    end

    subtotal_1      = base
    subtotal_2      = base + options_subtotal
    subtotal_3      = subtotal_2 - (discount_amount + (subtotal_2 * (discount_rate/100.0)))
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
                  
    return prices
  end  
    

  def state_hash
    {"Alabama" => "AL",
    "Alaska" => "AK",
    "Arizona" => "AZ",
    "Arkansas" => "AR",
    "California" => "CA",
    "Colorado" => "CO",
    "Connecticut" => "CT",
    "Delaware" => "DE",
    "District of Columbia" => "DC",
    "Florida" => "FL",
    "Georgia" => "GA",
    "Hawaii" => "HI",
    "Idaho" => "ID",
    "Illinois" => "IL",
    "Indiana" => "IN",
    "Iowa" => "IA",
    "Kansas" => "KS",
    "Kentucky" => "KY",
    "Louisiana" => "LA",
    "Maine" => "ME",
    "Maryland" => "MD",
    "Massachusetts" => "MA",
    "Michigan" => "MI",
    "Minnesota" => "MN",
    "Mississippi" => "MS",
    "Missouri" => "MO",
    "Montana" => "MT",
    "Nebraska" => "NE",
    "Nevada" => "NV",
    "New Hampshire" => "NH",
    "New Jersey" => "NJ",
    "New Mexico" => "NM",
    "New York" => "NY",
    "North Carolina" => "NC",
    "North Dakota" => "ND",
    "Ohio" => "OH",
    "Oklahoma" => "OK",
    "Oregon" => "OR",
    "Pennsylvania" => "PA",
    "Rhode Island" => "RI",
    "South Carolina" => "SC",
    "South Dakota" => "SD",
    "Tennessee" => "TN",
    "Texas" => "TX",
    "Utah" => "UT",
    "Vermont" => "VT",
    "Virginia" => "VA",
    "Washington" => "WA",
    "West Virginia" => "WV",
    "Wisconsin" => "WI",
    "Wyoming" => "WY"}
  end
end