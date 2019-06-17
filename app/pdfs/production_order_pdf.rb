require 'stringio'
require 'prawn'
require 'prawn/table'

def feature_fixer(order, name)
  if(order.created_at > Date.parse('2017-01-30'))
    name.gsub('Premier', 'Solid Pine').gsub('Deluxe', 'Duratemp')
  else
    name
  end
end

def style_fixer(order, name)
  if(order.created_at > Date.parse('2017-01-30'))
    name.gsub('Mini', 'Manchester').gsub('Cottage', 'Newbury')
  else
    name
  end
end  

class ProductionOrderPdf < Prawn::Document
  include ApplicationHelper
  
  def logo
    logopath =  "#{Rails.root}/app/assets/images/logo.png"
    image logopath, :width => 250 #, :height => 110
  end
  
  def business_address
    ["1696 State Route 39 . Sugarcreek, OH   44681", "P 330.852.2103 / Fax 330.852.7804"]
  end
  
  def special_instructions(order)   
    info = [['Salesman', order.salesperson.andand.name],
            ['Date', order.date.andand.strftime("%m/%d/%Y")],
            ["Site Ready Date", "#{order.site_ready_date.andand.strftime("%m/%d/%Y")} (#{order.site_ready ? "ready" : "not ready"})"],
            ['Delivery Date', order.delivery_date.andand.strftime("%m/%d/%Y")],
            ['Estimated Time', order.estimated_time],
            ['Crew', order.crew]]
            
     table(info, {column_widths: [bounds.width/2, bounds.width/2], cell_style: {size: 9, padding: [2, 2, 2, 2]}}) do
      cells.borders = [:bottom]
    end 
       
    bounding_box([0, 0], width: bounds.width, height: 200) do
      stroke_bounds
      font_size 10
      pad(5) {text "Notes:", :indent_paragraphs => 10}
      
      #text_size = @order.notes.length > 200 ? 5 : 8
      
      #text @order.notes, size: text_size, :indent_paragraphs => 10
      text_box(@order.notes, at: [10, bounds.height- 20], width: bounds.width - 15, height: bounds.height - 30, overflow: :shrink_to_fit)
      
      font_size 8
    end
  end
    
  def customer_input
    table([["How did you hear about us?", "Customer Signature x"]], column_widths: [bounds.width/2, bounds.width/2]) do
      cells.borders = [:bottom]
    end
  end
  
  def options(json)
    text "Size: #{json['data']['options']['size']['width']} x #{json['data']['options']['size']['len']}"
    text "Style: #{json['data']['options']['style']}"
    text "Feature: #{json['data']['options']['feature']}"
    text "Build: #{json['data']['options']['build_type']}"
  end
  
  def barn_type(json)
    puts "*" * 100
    puts json['data']['options']['style']
    if(json['data']['options']['size'] == 'Custom')
      width   = json['data']['custom']['size']['width']
      length  = json['data']['custom']['size']['len']
      
      puts width
      puts length
    else
      width = json['data']['options']['size']['width']
      length = json['data']['options']['size']['len']
    end

    feature = json['data']['options']['feature']
    feature = json['data']['custom']['feature'] if(feature == 'Custom')
        
    table([[ "Size: #{width} x #{length}",
              "Style: #{style_fixer(@order, json['data']['options']['style'])}",
              "Feature: #{feature_fixer(@order, feature)}",
              {content: "<b>#{json['data']['options']['build_type'].upcase}</b>", inline_format: true}, 
              "Barnsiding - #{[json['data']['options']['orientation'], json['data']['options']['side_out']].reject(&:blank?).join(',')}",
            ]], column_widths: [bounds.width/8, bounds.width/4,bounds.width/4,bounds.width/8,bounds.width/4], cell_style: {padding: 2})
  end
  
  def general_info(order)
    info = [['Salesman', order.salesperson.andand.name],
            ['Date', order.created_at.andand.strftime("%m/%d/%Y")],
            ["Site Ready Date", "#{order.site_ready_date.andand.strftime("%m/%d/%Y")} (#{order.site_ready ? "ready" : "not ready"})"],
            ['Delivery Date', order.delivery_date.andand.strftime("%m/%d/%Y")],
            ['Estimated Time', order.estimated_time],
            ['Crew', order.crew]]
  
    table(info, {column_widths: [bounds.width/4 - 50, (bounds.width/4)], cell_style: {size: 9, padding: [2, 2, 2, 2]}}) do
      cells.borders = [:bottom]
    end 
  end
  
  def additions(json, addition_start)
    total_items     = 0
    line_items      = sales_order_calculator(json, :money)[:sidebar_items]
    table_items     = []
    header          = [{content: '<b>Qty</b>', inline_format: true}, {content: '<b>Options</b>', inline_format: true}]

    line_items.each do |category|
      (category[:components]).each_with_index do |item, i|
        if(i == 0)
          table_items << [{colspan: 2, content: "<b>#{category[:category]}</b>", inline_format: true, background_color: 'F1F3DD'}]
        end
        
        quantity    = item[:quantity]   == 0        ? nil : item[:quantity]
        price       = item[:price]      == '$0.00'  ? nil : item[:price]
        unit_price  = item[:unit_price] == '$0.00'  ? nil : item[:unit_price]
        
        quantity  = quantity.to_i if (quantity.to_i == quantity)
        borders   = (i == category[:components].length - 1) ? [:left, :right, :bottom] : [:left, :right]
        
        table_items << [{content: quantity.to_s, borders: borders, inline_format: true}, {content: item[:name], borders: borders, inline_format: true}]
      end
    end
     
    move_cursor_to addition_start
    
    if(table_items.size > 30)
      max_line_items  = 30
      @second_page_required = true
    else
      max_line_items  = 16
    end
    
    if(table_items.size > max_line_items)
      additional_table_items = table_items[max_line_items + 1,table_items.size]
      table_items = table_items[0, max_line_items + 1]
      table_items.unshift(header)   
      table_items.last[0][:borders] << :bottom rescue nil
      table_items.last[1][:borders] << :bottom rescue nil
      
      if(!additional_table_items.empty?)
        if(!additional_table_items.andand.first.andand.first.andand.has_key?(:colspan))
          last_section_heading = table_items.select{|i| i && i.first.has_key?(:colspan)}.last
          additional_table_items.unshift(last_section_heading)
          
          table_items.pop if table_items.last.first.has_key?(:colspan)
        end
        
        additional_table_items.unshift(header)        
      end
               
    else
      table_items.unshift(header)   
      additional_table_items = nil
    end
    
    bounding_box([0, addition_start], :width => (bounds.width/3.0)) do
      table(table_items, {column_widths: [bounds.width/9, bounds.width * (7/9.0)], header: true, cell_style: {size: 9, padding: [2, 2, 2, 2]}})
    end
    
    if(additional_table_items && !additional_table_items.empty?)
      bounding_box([bounds.width* (1/3.0), addition_start], :width => (bounds.width/3.0)) do
       table(additional_table_items, {column_widths: [bounds.width/9, bounds.width * (7/9.0)], header: true, cell_style: {size: 9, padding: [2, 2, 2, 2]}})  
      end
    end
  end

  def initialize(order, json, view)
    super()
      @order = order
      @prices = JSON.load(order.prices)
      @second_page_required = false
      json = JSON.load(json)
      @json = json
      
      
      font_size 8
      move_up 40
      
      logo_start = cursor

      repeat(:all) do
        bounding_box([0, logo_start], :width => (bounds.width * 1), height: 150) do
          logo
          move_down 25
          font_size 20

          #move_cursor_to logo_start
          draw_text "Production Order #{order.id}", style: :bold, at: [bounds.width - 190, bounds.height - 30]
          text_box(order.customer.andand.name, width: 190, at: [bounds.width - 190, bounds.height- 40], leading: 2, size: 16)
          #draw_text "#{order.customer.andand.name}",              at: [bounds.width - 190, bounds.height]
          font_size 10
          #draw_text business_address[0], at: [bounds.width - 200, bounds.height - 45]
          #draw_text business_address[1], at: [bounds.width - 200, bounds.height - 55]
          font_size 8
        end
      end            

      bounding_box([bounds.left, cursor], width: bounds.width, height: bounds.height - 100) do
        move_up 60    
        page_start = cursor
        
        font_size 10
        barn_type(json)

        font_size 8
        move_down 10
        
        additions_start = cursor     

        bounding_box([bounds.width * 2/3.0, additions_start], :width => bounds.width/3) do
          special_instructions(order)
        end   

        
        #bounding_box([bounds.width/3.0 * 2, additions_start], :width => bounds.width/3, height: 90) do
        #  image(StringIO.new( Base64.decode64(@json['data']['base64'].split(',').last)), fit: [bounds.width, bounds.height - 200], at: [0, bounds.height - 75]) if order.image_string
        #end   
        
        additions(json, additions_start)
                
        if @second_page_required
          start_new_page
          image(StringIO.new( Base64.decode64(@json['data']['base64'].split(',').last)), fit: [bounds.width, bounds.height - 200], at: [0, bounds.height - 75]) rescue nil
        else        
          image(StringIO.new( Base64.decode64(@json['data']['base64'].split(',').last)), fit: [bounds.width, bounds.height/2], at: [0, bounds.height - 300]) rescue nil
        end
      end
  end
end
