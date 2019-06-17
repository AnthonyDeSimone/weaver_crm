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

class InvoicePdf < Prawn::Document
  include ApplicationHelper
  
  def logo
    logopath =  "#{Rails.root}/app/assets/images/logo.png"
    image logopath, :width => 250 #, :height => 110
  end
  
  def business_address
    team = @order.salesperson.sales_team
    
    if(team.show_company_on_invoice)
      [team.business_name, team.address, "P #{team.phone} / Fax #{team.fax}"]
    else
      ["1696 State Route 39 . Sugarcreek, OH   44681", "P 330.852.2103 / Fax 330.852.7804"]
    end
  
  end
  
  def approval_stamp
    "Approved by #{@order.final_approver.andand.name} on #{@order.final_approval_time.andand.strftime("%m/%d/%Y")}."
  end

  def term_lines
    if(Style.where(large_garage: true).pluck(:name).include?(@json['data']['options']['style']))
      <<-EOS
      Customer is responsible for preparation and permits.*
      Lot on which barn is to be placed must be level. *
      If site is not level, additional fee will be charged.*
      I received the paint/stain disclosure form (if I added paint or stain). *
      I received the foundation waiver form (if I added a post foundation). *
      Waste will be left with Customer or Removal for $45.00
      EOS
    elsif(Style.where(pavillion: true).pluck(:name).include?(@json['data']['options']['style']))
      <<-EOS
      Customer is responsible for preparation and permits.*
      Lot on which Structure is to be placed must be level. *
      If site is not level, additional fee will be charged.*
      I received the paint/stain disclosure form (if I added paint or stain). *
      I received the foundation waiver form (if I added a duracolumns). *
      Carrying Charge 10’ – 12’ Wide Structure 100' free-$1.00 per foot after 100'
      Carrying Charge 14’ – 20’ Wide Structure 50’ Free - $1.00 per foot after 50’
      Waste will be left with Customer or Removal for $45.00
      EOS
    else
      <<-EOS
      Customer is responsible for preparation and permits.*
      Lot on which barn is to be placed must be level. *
      If site is not level, additional fee will be charged.*
      I received the paint/stain disclosure form (if I added paint or stain). *
      I received the foundation waiver form (if I added a post foundation). *
      Carrying Charge 8’ – 12’ Wide Building 100' free-$1.00 per foot after 100'
      Carrying Charge 14’ – 16’ Wide Building 50’ Free - $1.00 per foot after 50’
      Waste will be left with Customer or Removal for $45.00
      EOS
    end
  end  
  
  def terms
    font_size 8.5
    move_down 5

    term_lines.split("\n").each do |line|
      text line, align: :center
    end
    
    bounding_box([(bounds.width/3).to_i, 22], width: (bounds.width/3).to_i) do 
      table([[{content: "<b><color rgb='FFFFFF'> TERMS C.O.D.</color></b>", inline_format: true}]], row_colors: ["EDA55C"]) do
        cells.borders = [:top, :left, :right, :bottom]
      end
    end
  end
  
  def special_instructions
    width = bounds.width
  
    if(@json['data'].andand['customer'].andand['shipping_same'])
      address_1 = " "
      address_2 = " "
    else
      address_1 = @json['data']['customer']['shipping']['address']
      address_2 = "#{@json['data']['customer']['shipping']['city']}, #{@json['data']['customer']['shipping']['state']} #{@json['data']['customer']['shipping']['zip']}"
    end
    
    table([ ["Ship to*", nil], 
            [" ", address_1], 
            [" ", address_2 ]], 
    {column_widths: [(bounds.width/2).to_i, (bounds.width/2).to_i], cell_style: {size: 9, padding: [2, 2, 2, 2]}}) do
      cells.borders = [:bottom]
    end
    
    move_down 10
    text "*If different than bill to"
    
    bounding_box([0, 0], width: bounds.width, height: 120) do
      stroke_bounds
      font_size 10
      pad(5) {text "Notes:", :indent_paragraphs => 10}
      
      text_box(@order.notes, at: [10, bounds.height- 20], width: width - 10, height: bounds.height - 30, overflow: :shrink_to_fit)
      
      font_size 8
    end
  end
  
  def charges(json)
    table_data =  [["Subtotal", @prices['subtotal_1']],
                  ["Options Subtotal", @prices['options_subtotal']],
                  ["Subtotal", @prices['subtotal_2']]]
                  
    #if(@prices['discount'].to_i != 0)
      table_data << [json['data']['fees']['advanced'].andand['special'], @prices['discount_total']] << ["*Subtotal", @prices['subtotal_3']] if(@prices['subtotal_3'] != "$0.00")
    #end
    
    county = json['data']['customer']['shipping']['county']
    county =  @order.customer.andand.county if county.blank?
    
    table_data << ["Delivery", @prices['delivery']]
    table_data << ["Subtotal", @prices['subtotal_4']]
    table_data << ["County (#{county}) Tax #{@prices['tax_rate']}%", @prices['tax']]
    table_data << ['Total', @prices['total']]
    table_data << ['Deposit', @prices['deposit']]
    table_data << ['Deposit Type', json['data']['fees']['deposit_type']]    
    table_data << ['Balance Due', @prices['balance_due']]
    table_data << ['Reference #', json['data']['extra']['reference']]
            

            
    table(table_data, column_widths: [(bounds.width/2).to_i, (bounds.width/2).to_i], cell_style: {size: 9, padding: [4, 4, 4, 4]})
            

  end
  
  def customer_input
    table([["How did you hear about us?", "Customer Signature x"]], column_widths: [(bounds.width/2).to_i, (bounds.width/2).to_i]) do
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
    if(json['data']['options']['size'] == 'Custom')
      width   = json['data']['custom']['size']['width']
      length  = json['data']['custom']['size']['len']
    else
      width = json['data']['options']['size']['width']
      length = json['data']['options']['size']['len']
    end
    
    feature = json['data']['options']['feature']
    feature = json['data']['custom']['feature'] if(feature == 'Custom')
    
    style = json['data']['options']['style']
    style = json['data']['custom']['structure_name'] if(style == 'Custom')
    
    font_size 9
    
    table([[ "Size: #{width} x #{length}",
              "Style: #{style_fixer(@order, style)}",
              "Feature: #{feature_fixer(@order, feature)}",
              {content: "<b>#{json['data']['options']['build_type'].upcase}</b>", inline_format: true}, 
              "Barnsiding - #{[json['data']['options']['orientation'], json['data']['options']['side_out']].reject(&:blank?).join(',')}",
            ]], row_colors: ["EDA55C", nil, nil], column_widths: [(bounds.width/8).to_i, (bounds.width/4).to_i, (bounds.width/4).to_i, (bounds.width/8).to_i,(bounds.width/4).to_i], cell_style: {padding: 2})
  end
  
  def general_info(order)
    info = [['Name', order.customer.andand.name],
            ['Address', order.customer.andand.address],
            ['City, State, Zip', "#{order.customer.andand.city}, #{order.customer.andand.state} #{order.customer.andand.zip}"],
            ['County', order.customer.andand.county],
            ['Primary Phone', order.customer.andand.primary_phone],
            ['Secondary Phone', order.customer.andand.secondary_phone],
            ['Email', order.customer.andand.email],
            ['Salesman', order.salesperson.andand.name],
            ['Date', order.date.andand.strftime("%m/%d/%Y")],
            ["Site Ready Date", "#{order.site_ready_date.andand.strftime("%m/%d/%Y")} (#{order.site_ready ? "ready" : "not ready"})"],
            ['Delivery Date', order.delivery_date.andand.strftime("%m/%d/%Y")],
            ['Estimated Time', order.estimated_time],
            ['Crew', order.crew],
            (['Updated By', @change_order_created_by.name] if @change_order_created_by)].compact
  
    table(info, {column_widths: [(bounds.width/4).to_i - 50, (bounds.width/4).to_i], cell_style: {size: 9, padding: [2, 2, 2, 2]}}) do
      cells.borders = [:bottom]
    end 
  end
  
  def additions(json, addition_start)
    line_items = sales_order_calculator(json, :money)[:sidebar_items]

    table_items = [['Qty', 'Options', 'Each', 'Total']]
    line_items.each do |category|
      (category[:components]).each_with_index do |item, i|        
        if(i == 0)
          table_items << [{colspan: 4, content: "<b>#{category[:category]}</b>", inline_format: true, background_color: 'F1F3DD'}]
        end
                
        quantity    = item[:quantity]   == 0        ? nil : item[:quantity]
        price       = item[:price]      == '$0.00'  ? nil : item[:price]
        unit_price  = item[:unit_price] == '$0.00'  ? nil : item[:unit_price]
        
        quantity = quantity.to_i if (quantity.to_i == quantity)
        borders   = (i == category[:components].length - 1) ? [:left, :right, :bottom] : [:left, :right]
        
        table_items << [{content: quantity.to_s, borders: borders}, {content: item[:name], borders: borders}, {content: unit_price, borders: borders}, {content: price, borders: borders}]
      end
      
      if(category[:category] == "Paint & Stain" && category[:components].any? {|c| c[:name].andand.match(/stain/i)})
        table_items << [nil, "(See Paint Disclosure)", nil, nil]
      elsif(category[:category] == "Paint & Stain" && category[:components].any? {|c| c[:name].andand.match(/paint/i)})
        table_items << [nil, "(See Paint Disclosure)", nil, nil]      
      elsif(category[:category] == "Foundation" && category[:components].any? {|c| c[:name].andand.match(/drop slope height/i)})
        table_items << [nil, "(See Waiver Form)", nil, nil] 
      end
    end
    
    move_cursor_to addition_start
    table(table_items, {column_widths: [(bounds.width/20).to_i, (bounds.width/4).to_i, (bounds.width/12).to_i, (bounds.width/12).to_i], header: true, cell_style: {size: 9, padding: [2, 2, 2, 2]}})  
  end

  def initialize(order, json, prices, revision, view, change_order_created_by = nil)
    super()
    create_pdf(order, json, prices, revision, view, change_order_created_by)
  end
  
  def create_pdf(order, json, prices, revision, view, change_order_created_by = nil)
      @view = view
      @order = order
      @revision = revision
      @prices = JSON.load(prices)
      font_size 8
      json = JSON.load(json)
      @json = json
      @change_order_created_by = change_order_created_by
      
      move_up 40
      logo_start = cursor

      repeat(:all) do
        bounding_box([0, logo_start], :width => (bounds.width * 1), height: 150) do
          logo
          move_down 25
          font_size 20
          #move_cursor_to logo_start
          heading = @order.issued ? "Order #{order.id}" : "Quote #{order.id}" 
          heading += "-#{@revision}" if @revision
          
          draw_text heading, style: :bold, at: [bounds.width - 100, bounds.height - 30]
          font_size 10
          draw_text business_address[0], at: [bounds.width - 200, bounds.height - 45]
          draw_text business_address[1], at: [bounds.width - 200, bounds.height - 55]
          draw_text business_address[2], at: [bounds.width - 200, bounds.height - 65] if business_address[2]
          draw_text(approval_stamp, at: [bounds.width - 200, bounds.height - 75], style: :bold, size: 8) if @order.final_approval
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
    
        bounding_box([(bounds.width/2).to_i, additions_start], :width => (bounds.width/2).to_i) do
          charges(json)
        end   
        
        bounding_box([(bounds.width/2).to_i, page_start], :width => bounds.width/2) do
          special_instructions
        end   
        
        bounding_box([(bounds.width/2).to_i, 150], :width => (bounds.width/2).to_i, height: 130) do
          stroke_bounds
          terms
          font_size 8
        end   
                          
        additions(json, additions_start)

        if(Style.where(pavillion: true).pluck(:name).exclude?(@json['data']['options']['style']))
          start_new_page
          image(StringIO.new( Base64.decode64(@json['data']['base64'].split(',').last)), fit: [bounds.width, bounds.height - 200], at: [0, bounds.height - 75]) rescue nil
        end 

        bounding_box([0, 10], :width => bounds.width) do
          customer_input
        end
      end
  end
end
