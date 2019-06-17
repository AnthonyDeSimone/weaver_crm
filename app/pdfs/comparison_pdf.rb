require 'stringio'
require 'prawn'
require 'prawn/table'

def feature_fixer(order, name)
  if(order.created_at > Date.parse('2017-01-30'))
    name.gsub('Premier', 'Solid Pine').gsub('Deluxe', 'Duratemp')
  else
    name.gsub("Pavillion", '')
  end
end

def style_fixer(order, name)
  if(order.created_at > Date.parse('2017-01-30'))
    name.gsub('Mini', 'Manchester').gsub('Cottage', 'Newbury')
  else
    name
  end
end  

class ComparisonPdf < Prawn::Document
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
      ["1696 State Route 39", "Sugarcreek, OH 44681", "(888) 289-4940"]
    end
  
  end
  
  def approval_stamp
    "Approved by #{@order.final_approver.andand.name} on #{@order.final_approval_time.andand.strftime("%m/%d/%Y")}."
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
      
      if(category[:category] == "Paint & Stain" && category[:components].any? {|c| c[:name].match(/stain/i)})
        table_items << [nil, "(See Paint Disclosure)", nil, nil]
      elsif(category[:category] == "Paint & Stain" && category[:components].any? {|c| c[:name].match(/paint/i)})
        table_items << [nil, "(See Paint Disclosure)", nil, nil]      
      elsif(category[:category] == "Foundation" && category[:components].any? {|c| c[:name].match(/drop slope height/i)})
        table_items << [nil, "(See Waiver Form)", nil, nil] 
      end
    end
    
    move_cursor_to addition_start
    table(table_items, {column_widths: [(bounds.width/20).to_i, (bounds.width/4).to_i, (bounds.width/12).to_i, (bounds.width/12).to_i], header: true, cell_style: {size: 9, padding: [2, 2, 2, 2]}})  
  end

  def initialize(order, json, prices, revision, view, change_order_created_by = nil)
    @json = json
    @order = order
    super()

    font_families.update("ebrima" => {
        :normal => Rails.root.join(".fonts/ebrima.ttf"),
        :bold => Rails.root.join(".fonts/ebrimabd.ttf")
    }
    )    
    
    font "ebrima"

    create_pdf(order, json, prices, revision, view, change_order_created_by)
  end
  
  def subtext
    if(@json['data']['options']['build_type'].downcase == 'prebuilt')
      "Prebuilt & Delivered"
    else
      "Assembled On Site"
    end
  end

  def base_price(feature_name)
    key = StyleKey.find_by(style:   Style.find_by_name(@json['data']['options']['style']), 
                              width:  @json['data']['options']['size']['width'], 
                              length: @json['data']['options']['size']['len'], 
                              feature: feature_name)

    JSON.load(key.zone_prices)["zone_#{@json['data']['options']['zone']}"][@json['data']['options']['build_type']]['base'] 
  end

  def options_subtotal(feature_name)
    @temp_json[:data][:options]['feature'] = feature_name
    @temp_json[:data][:additions] = ApplicationController.new.helperer(@temp_json)

    result = sales_order_calculator(@temp_json, :money, false, true)

    result[:prices][:options_subtotal]
  end

  def create_pdf(order, json, prices, revision, view, change_order_created_by = nil)
    draw_text "It's Your Choice", :at => [0,650], :size => 32
    image     "#{Rails.root}/public/pdf_images/Weaver Barns Logo Square.jpg", :at => [400,750], :width => 160  
    
    @order = order
    
    current_feature = json['data']['options']['feature'].dup

    stroke do
      horizontal_line 0, 550, :at => 625
      horizontal_line 0, 550, :at => 624

      horizontal_line 0, 550, :at => 25
    end

    barn_size = "#{json['data']['options']['size']['width']} x #{json['data']['options']['size']['len']}"\
                " #{json['data']['options']['style']}"

    move_cursor_to 600
    text barn_size, :size => 40, align: :center
    text subtext.upcase, size: 22, align: :center

    
    features = ['Eco Pro', 'Deluxe', 'Premier', 'Vinyl']
    prices = {}

    @temp_json = JSON.load(@order.json_info).with_indifferent_access
    @temp_json[:data] = @temp_json[:data].with_indifferent_access

    features.each do |feature|
      if(feature_fixer(order, current_feature) == feature_fixer(order, feature))
        order_prices = JSON.load(order.prices)

        prices[feature] = { base: order_prices['base'], 
                            options_subtotal: order_prices['options_subtotal'], 
                            total: order_prices['subtotal_2'], 
                            selected: {image: open("#{Rails.root}/public/pdf_images/check_2.png"), image_width: 25, borders: []}
                          }
      else
        base = base_price(feature)
        options_subtotal = options_subtotal(feature).delete("$,").to_i
        total = base + options_subtotal
        prices[feature] = { base: view.number_to_currency(base), 
                            options_subtotal: view.number_to_currency(options_subtotal), 
                            total: view.number_to_currency(total),
                            selected: {content: nil, borders: []}}
      end
    end

    bounding_box([0, 350], :width => bounds.width, :height => 400) do
      table_data = []

      table_data << [{content: nil, borders: []},
                     {content: nil, borders: []},
                     {content: 'Base Price', borders: [:right]},
                     {content: 'Options Subtotal', align: :center, borders: [:right]},
                     {content: "Subtotal*<br><font size='6'>Does Not Include Tax</font>", inline_format: true, align: :center, borders: []}
                    ]

      table_data << [ prices['Eco Pro'][:selected],
                      {:image => open("#{Rails.root}/public/pdf_images/ECO PRO.PNG"), image_width: 100, position: :right, borders: [:right]}, 
                      {content: prices['Eco Pro'][:base], inline_format: true, align: :center, borders: [:right]}, 
                      {content: prices['Eco Pro'][:options_subtotal], align: :center,inline_format: true, borders: [:right]}, 
                      {content: prices['Eco Pro'][:total], align: :center,inline_format: true, borders: []}
                    ]

      table_data << [ prices['Deluxe'][:selected],
                      {content: '<b>DURATEMP</b> SIDING', inline_format: true, align: :right, borders: [:right]}, 
                      {content: prices['Deluxe'][:base], inline_format: true, align: :center, borders: [:right]}, 
                      {content: prices['Deluxe'][:options_subtotal], align: :center,inline_format: true, borders: [:right]}, 
                      {content: prices['Deluxe'][:total], align: :center,inline_format: true, borders: []}
                      ]

      table_data << [ prices['Premier'][:selected],
                      {content: '<b>SOLID PINE</b> SIDING', inline_format: true, align: :right, borders: [:right]}, 
                      {content: prices['Premier'][:base], inline_format: true, align: :center, borders: [:right]}, 
                      {content: prices['Premier'][:options_subtotal], align: :center,inline_format: true, borders: [:right]}, 
                      {content: prices['Premier'][:total], align: :center,inline_format: true, borders: []}
                      ]

      table_data << [ prices['Vinyl'][:selected],
                      {content:'<b>VINYL</b> SIDING', inline_format: true, align: :right, borders: [:right]}, 
                      {content: prices['Vinyl'][:base], inline_format: true, align: :center, borders: [:right]}, 
                      {content: prices['Vinyl'][:options_subtotal], align: :center,inline_format: true, borders: [:right]}, 
                      {content: prices['Vinyl'][:total], align: :center,inline_format: true, borders: []}
                      ]

      table(table_data, row_colors: ["FFFFFF", "F1F1F1", "E5E6E8", "F1F1F1", "E5E6E8"], 
                        column_widths: [30, 170,90, 150,100],
                        :cell_style => { height: 50, :size => 15, border_color: "CECFD1"})
    end




    starting = -25

    circles =['Eco Pro.png', 'Duratemp.png', 'Pine Siding.png', 'Vinyl Siding.png']

    circles.each do |circle|
      image "#{Rails.root}/public/pdf_images/#{circle}", :at => [starting,525], :width => 155  
      starting+= 145
    end


    draw_text order.customer.andand.name || "Customer Name", :size => 34, at: [0, 50]

    data = [[{content: "Quote #{@order.id}", size: 16}]] + (business_address << "Salesperson: #{@order.salesperson.name}").map {|row| [{content: row, :size => 7}]}

    bounding_box([400, 100], :width => 300, :height => 75) do
      table data, :cell_style => { padding: 2, borders: []}
    end


    move_cursor_to 20
    text "www.weaverbarns.com", align: :center
    #

    # text "Prison Comparison Quick View"
    # text "Prepared for #{order.customer.name}" if order.customer
    # text "Prepared by #{order.salesperson.name}"
    # text "* Subtotal does not include tax"


  end
end
