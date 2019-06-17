require 'stringio'
require 'prawn'
require 'prawn/table'

class ServiceTicketPdf < Prawn::Document
  include ApplicationHelper
  
  def logo
    logopath =  "#{Rails.root}/app/assets/images/logo.png"
    image logopath, :width => 250 #, :height => 110
  end
  
  def business_address
    ["1696 State Route 39 . Sugarcreek, OH   44681", "P 330.852.2103 / Fax 330.852.7804"]
  end
  
  
  def notes   
    width = bounds.width
      
    bounding_box([0, 0], width: bounds.width, height: 120) do
      stroke_bounds
      font_size 10
      pad(5) {text "Notes:", :indent_paragraphs => 10}
      
      text_box(@ticket.notes, at: [10, bounds.height- 20], width: width - 10, height: bounds.height - 30, overflow: :shrink_to_fit)
      
      font_size 8
    end
  end
  
  def charges
    table_data =  [[{content: '<b>Work Items</b>', borders: [], inline_format: true}, {content: '', borders: [], inline_format: true}]]
    
    table_data << [{content: '<b>Description</b>', borders: [], inline_format: true}, {content: '<b>Cost</b>', borders: [], inline_format: true}]
               
    @json['ticket']['service_description'].andand.each do |item|
      table_data << [item['description'], item['cost']]
    end 
 
    3.times { |n| table_data << ([{content: ' ', borders: []}] * 2) }
    
    table_data << [{content: '<b>Materials</b>', borders: [], inline_format: true}, {content: '', borders: [], inline_format: true}]
    
    @json['ticket']['service_material'].andand.each do |item|
      table_data << [item['description'], nil] unless item['description'].blank?
    end     
        
    3.times { |n| table_data << ([{content: ' ', borders: []}] * 2) }

    table_data << [{content: '<b>Charges</b>', borders: [], inline_format: true}, {content: '', borders: [], inline_format: true}]
    table_data << ["Subtotal", @view.number_to_currency(@json['ticket']['subtotal_1'])]
    table_data << ["Delivery", @view.number_to_currency(@json['ticket']['delivery'])]
    table_data << ["Subtotal", @view.number_to_currency(@json['ticket']['subtotal_2'])]
    table_data << ["Tax (#{@json['ticket']['tax']}%)", @view.number_to_currency(@json['ticket']['tax_amount'])]
    table_data << ([{content: ' ', borders: []}] * 2)
    table_data << ['Total', @view.number_to_currency(@json['ticket']['total'])]            


            
    table(table_data, column_widths: [bounds.width/2, bounds.width/2], cell_style: {size: 9, padding: [4, 4, 4, 4]})
  end
    
  def general_info
    time_frames = {'fd' => "Full Day", 'hd' => "Half Day", 'thl' => "2 Hours or Less"}
    info = [[{content: '<b>Customer Information</b>', borders: [], inline_format: true}, {content: nil, borders: []}],
            ['Name', @ticket.customer.andand.name],
            ['Primary Phone', @ticket.customer.andand.primary_phone],
            ['Secondary Phone', @ticket.customer.andand.secondary_phone],
            ['Email', @ticket.customer.andand.email],
            ['Secondary Email', nil], #@ticket.customer.andand.secondary_email],
           ([{content: ' ', borders: []}] * 2),
            [{content: '<b>Billing Address</b>', borders: [], inline_format: true}, {content: nil, borders: []}],
            ['Address', @json['ticket']['customer']['address']],
            ['City', @json['ticket']['customer']['city']],
            ['State', @json['ticket']['customer']['state']],
            ['Zip', @json['ticket']['customer']['zip']],
            ['County', @json['ticket']['customer']['county']],
           ([{content: ' ', borders: []}] * 2),       
            [{content: '<b>Shipping Address</b>', borders: [], inline_format: true}, {content: nil, borders: []}],
            ['Address', @json['ticket']['customer']['shipping']['address']],
            ['City', @json['ticket']['customer']['shipping']['city']],
            ['State', @json['ticket']['customer']['shipping']['state']],
            ['Zip', @json['ticket']['customer']['shipping']['zip']],
            ['County', @json['ticket']['customer']['shipping']['county']],
           ([{content: ' ', borders: []}] * 2),       
            [{content: '<b>Misc</b>', borders: [], inline_format: true}, {content: nil, borders: []}],            
            ['Date', @json['ticket']['date']],
            ['Time Frame', time_frames[@json['ticket']['time_frame']]],
            ['Site Visit', @json['ticket']['site_visit'] == true ? "yes" : "no"],
            ['Customer Needs to be present', @json['ticket']['customer_present_required'] == true ? "yes" : "no"]]
            
              
    table(info, {column_widths: [bounds.width/4 - 50, (bounds.width/4)], cell_style: {size: 9, padding: [2, 2, 2, 2]}}) do
      #cells.borders = [:bottom]
    end 
  end

  def initialize(ticket, view)
    super()
    create_pdf(ticket, view)
  end
  
  def create_pdf(ticket, view)
      @ticket = ticket
      @json = JSON.load(@ticket.info)
      @prices = @json['prices']
      @view = view
      
      font_size 8
            
      move_up 40
      logo_start = cursor

      repeat(:all) do
        bounding_box([0, logo_start], :width => (bounds.width * 1), height: 150) do
          logo
          move_down 25
          font_size 20
          #move_cursor_to logo_start
          heading = "Service Ticket #{@ticket.id}"
          
          draw_text heading, style: :bold, at: [bounds.width - 150, bounds.height - 30]
          font_size 10
          draw_text business_address[0], at: [bounds.width - 200, bounds.height - 45]
          draw_text business_address[1], at: [bounds.width - 200, bounds.height - 55]

          font_size 8
        end
      end            
      
      additions_start = cursor

      bounding_box([bounds.left, cursor], width: bounds.width, height: bounds.height - 100) do
        move_up 60    
        page_start = cursor

        font_size 7
        general_info
        move_down 15
        
        #barn_type(json)

        font_size 8
        move_down 10
         
    
        bounding_box([bounds.width/2, additions_start - 50], :width => bounds.width/2) do
          charges
        end   
        
        bounding_box([bounds.width/2, page_start], :width => bounds.width/2) do
          notes
        end   
      end
  end
end
