require 'stringio'

class CustomInvoicePdf < InvoicePdf
  include ApplicationHelper
  
  def options_3
    options = ['permits', 'utility services', 'driveway details', 'excavation', 'foundation',
                'concrete work', 'well', 'septic', 'gassetup', 'plumbing', 'electrical', 
                'HVAC', 'flooring', 'kitchen & vanities', 'appliances', 'closet organization']
                
    options.each do |option|
      note = "There #{option.chop == 's' ? 'are' : 'is'} no #{option} included in this price"
      table([[option, note]])
      move_down 10
    end
  
  end

  def additions(json, addition_start)
    line_items = sales_order_calculator(json, :money, true)[:sidebar_items]

    table_items_1 = [['Qty', 'Options', 'Each', 'Total']]
    table_items_2 = []
    table_items_3 = []
    
    total_price = 0
          
    line_items.each do |category|
      sorted_line_items_1 = {}
      sorted_line_items_2 = {}
      sorted_line_items_3 = {}
      
      (category[:components]).each do |item|
        next unless item
        
        if(category[:category] == 'Options I')
          sorted_line_items_1[item[:subcategory]] ||= []
          sorted_line_items_1[item[:subcategory]] << item
        elsif(category[:category] == 'Options II')
          sorted_line_items_2[item[:subcategory]] ||= []
          sorted_line_items_2[item[:subcategory]] << item        
        else
          sorted_line_items_3[item[:subcategory]] ||= []
          sorted_line_items_3[item[:subcategory]] << item            
        end
      end

      sorted_line_items_1.each_pair do |subcategory, items|
        table_items_1 << [nil, {content: "<b>#{subcategory}<b>", background_color: 'C3D69B', inline_format: true} , nil, nil]
        
        items.each do |item|          
          quantity    = item[:quantity]   == 0        ? nil : item[:quantity]
          price       = item[:price]      == '$0.00'  ? nil : item[:price]
          unit_price  = item[:unit_price] == '$0.00'  ? nil : item[:unit_price]
          
          quantity = quantity.to_i if (quantity.to_i == quantity)
          
          table_items_1 << [quantity, item[:description] || " ", unit_price, price]
        end
      end
            
      sorted_line_items_2.each_pair do |subcategory, items|
        table_items_2 << [{content: subcategory, background_color: 'FCD5B5'},
                          {content: "There #{subcategory[-1,1] == 's' ? 'are' : 'is'} no #{subcategory} included in this price", background_color: 'FCD5B5'}, 
                          {content: nil, background_color: 'FCD5B5'}]

        items.each do |item|          
          price       = item[:price]      == '$0.00'  ? nil : item[:price]
          
          table_items_2 << [item[:name], item[:description], price]
          total_price += price.andand.gsub(/\$/, '').to_f
        end
      end

      sorted_line_items_3.each_pair do |subcategory, items|
        table_items_3 << [{content: subcategory, background_color: 'C3D69B'},
                          {content: "There #{subcategory[-1,1] == 's' ? 'are' : 'is'} no #{subcategory} included in this price", background_color: 'C3D69B'}, 
                          {content: nil, background_color: 'C3D69B'}]

        items.each do |item|          
          price       = item[:price]      == '$0.00'  ? nil : item[:price]
          
          table_items_3 << [item[:name], item[:description], price]
          total_price += price.andand.gsub(/\$/, '').to_f
        end
      end
    end
        
    table_items_2 << [{content: nil, borders: []}, {content: nil, borders: []}, {content: nil, borders: []}]
    table_items_2 << [{content: nil, borders: []}, {content: nil, borders: []}, {content: "Price: #{@view.number_to_currency(total_price)}", borders: []}]

    table_items_3 << [{content: nil, borders: []}, {content: nil, borders: []}, {content: nil, borders: []}]
    table_items_3 << [{content: nil, borders: []}, {content: nil, borders: []}, {content: "Price: #{@view.number_to_currency(total_price)}", borders: []}]
        
    move_cursor_to addition_start
    table(table_items_1, {column_widths: [bounds.width/20, bounds.width/4, bounds.width/12, bounds.width/12], header: true, cell_style: {size: 9, padding: [2, 2, 2, 2]}})  
    
    start_new_page
    
    text "Options II", size: 10, style: :bold
    move_down 10
    
    table(table_items_2, {column_widths: [bounds.width/4, bounds.width/2, bounds.width/4], cell_style: {size: 9, padding: [2, 2, 2]}})  
    
    text "Options III", size: 10, style: :bold
    move_down 10
    
    table(table_items_3, {column_widths: [bounds.width/4, bounds.width/2, bounds.width/4], cell_style: {size: 9, padding: [2, 2, 2]}})  

  end
  
  def initialize(order, json_info, prices, revision, view, change_order_created_by= nil)
    @view = view
    super(order, json_info, prices, revision, view, change_order_created_by)
  end
  
  def create_pdf(order, json_info, prices, revision, view, change_order_created_by = nil)
      @order = order
      @prices = JSON.load(prices)
      font_size 8
      json = JSON.load(json_info)
      @json = json
      @revision = revision
      @prices = JSON.load(prices)
      @change_order_created_by = change_order_created_by
           
      move_up 40
      logo_start = cursor

      repeat(:all) do
        bounding_box([0, logo_start - 15], :width => (bounds.width * 1), height: 150) do
          logo
          move_down 25
          font_size 20
          puts logo_start.inspect
          #move_cursor_to logo_start
          heading = @order.issued ? "Order #{order.id}" : "Quote #{order.id}" 
          heading += "-#{@revision}" if revision
                    
          draw_text heading, style: :bold, at: [bounds.width - 120, bounds.height - 30]
          font_size 10
          draw_text business_address[0], at: [bounds.width - 200, bounds.height - 45]
          draw_text business_address[1], at: [bounds.width - 200, bounds.height - 55]
          font_size 8
        end
      end            

      bounding_box([bounds.left, cursor], width: bounds.width, height: bounds.height - 100) do
        move_up 60    
        page_start = cursor

        font_size 7
        general_info(order)
        move_down 15
        
        barn_type(json)

        font_size 8
        move_down 10
        
        additions_start = cursor     
    
        bounding_box([bounds.width/2, additions_start], :width => bounds.width/2) do
          charges(json)
        end   
        
        bounding_box([bounds.width/2, page_start], :width => bounds.width/2) do
          special_instructions
        end   
        
        bounding_box([(bounds.width/2).to_i, 150], :width => (bounds.width/2).to_i, height: 130) do
          stroke_bounds
          terms
          font_size 8
        end   
                          
        additions(json, additions_start)
        
        start_new_page
        
        image(StringIO.new( Base64.decode64(@json['data']['base64'].split(',').last)), fit: [bounds.width, bounds.height - 200], at: [0, bounds.height - 75]) rescue nil
                     
        bounding_box([0, 25], :width => bounds.width) do
          customer_input
        end
      end
  end
end
