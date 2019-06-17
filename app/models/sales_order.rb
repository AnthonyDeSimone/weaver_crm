require 'zlib'
require 'csv'
require 'fishbowl'
require 'dropbox'
require 'geocoder'

class SalesOrder < ActiveRecord::Base 
  INFUSIONSOFT_TAG_KEYS = {
                          'Cottage' => 109,
                          'Gable' => 111,
                          'Estate' => 113,
                          'Mini' => 115,
                          'Sugarcreek' => 117,
                          'Highland' => 119,
                          'Woodshed' => 121,
                          'Craftsman' => 125,
                          'Cambrel Cabin' => 127,
                          'A-Frame Cabin' => 129,
                          'Cedar Brooke' => 131,
                          'Dutch Barn' => 133,
                          'Garage' => 135,
                          'Timber Lodge' => 137,
                          'Custom' => 139,
                          'Studio' => 4830,
                          'Timber Ridge' => 4821,
                          'Bradord' => 4824,
                          'Dublin' => 4826
                          }
                          
  enum status:        [ :Quote, :Live, :Site_Ready, :Working_On_Site, :Scheduled, :Load_Complete, :Change_Order]
  enum build_type:    [ :aos, :prebuilt ]
  enum build_status:  [:unavailable, :ready_to_process, :in_production, :completed]

  has_many :special_order_items

  after_save :build_special_order_items
  
  def build_special_order_items
    reload
    items = JSON.load(self.json_info)['data']['special_order']
    
    if(items)
      items.each do |item|
        special_order_item = self.special_order_items.where(name: item['name']).first_or_create
        
        special_order_item.update(required: item['required'], po_number: item['po_number'], ordered: item['ordered'], notes: item['notes'])
      end
    end
  end

  def update_lock_status!
    if(locked_at && locked_at < 1.5.minutes.ago)
      update!(locked_by: nil, locked_at: nil)
    end
  end

  def unlocked?
    locked_by.nil? && locked_at.nil?
  end
  
  def locked?
    !unlocked?
  end
  
  def lock!(salesperson)
    update!(locked_by: salesperson, locked_at: Time.now)
  end

  def real_status
    if(open)
      status 
    else
      'Closed'
    end
  end

  def json_info=(json)
    write_attribute(:json_info, Zlib::Deflate.deflate(json))
  end

  def image_string
    Zlib::Inflate.inflate(read_attribute(:image_string)) rescue nil
  end

  def image_string=(image_string)
    write_attribute(:image_string, Zlib::Deflate.deflate(image_string)) unless image_string.nil?
  end

  def json_info
    Zlib::Inflate.inflate(read_attribute(:json_info))
  end

  def statuses
    [ :unissued, :active, :site_ready, :scheduled ]
  end

  def self.build_statuses
    [:unavailable, :ready_to_process, :in_production, :completed]
  end

  def full_address
    "#{customer_address} #{customer_city}, #{customer_state} #{customer_zip}"
  end
  
  def html_summary
    summary = []
    summary << "#{customer.address} #{customer.city}, #{customer.state}"
    summary << "Style + Dimensions"
    summary << "#{delivery_date.strftime('%m/%d/%Y')}" if status == :scheduled
    summary << Rails.application.routes.url_helpers.sales_order_path(id)
  end
  
  def confirm(confirmed)
    self.status = (confirmed ? :live : :unissued)
    self.date = Time.now if confirmed
    self.issued = confirmed
    self.save
  end
  
  def special_order_warnings
    self.special_order_items.where(required: true, ordered: false).map do |item|
      "#{item.name} still must be ordered."
    end || []
    
    #~ JSON.load(self.special_order_items).andand.map do |item|
      #~ "#{item['name']} still must be ordered."
    #~ end || []
  end
  
  def prebuilt_status_pin
    if(self.build_type == 'prebuilt' && self.build_status == 'in_production')
      'green_flag'
    elsif(self.build_type == 'prebuilt' && self.build_status == 'completed')
      'blue_flag'
    else
      nil
    end  
  end
  
  def get_pin
    icon = if(self.status == 'Load_Complete')
      'black_pin'
    elsif(self.status == 'Working_On_Site')
      'white_pin'
    elsif(self.status == 'Scheduled')
      'green_pin'
    elsif(self.status == 'Site_Ready')
      prebuilt_status_pin || 'yellow_pin'
    elsif(self.date.advance(months: 8) < Date.today)
      'blue_pin'
    else
      prebuilt_status_pin || 'red_pin'
    end

    if(!final_approval)
      icon.sub!('pin', 'circle')
    end

    icon
  end
  
  def self.this_months_orders(user, build_type)
    if(['Admin', 'Internal Sales Manager'].include?(user.account_type))
      SalesOrder.where(build_type: SalesOrder.build_types[build_type]).where(date: Time.now.beginning_of_month..Time.now.end_of_month)
    elsif(['Dealer Sales Manager', 'Dealer Salesman'].include?(user.account_type))
      salespeople = user.sales_team.salespeople
      SalesOrder.where(salesperson: salespeople, build_type: SalesOrder.build_types[build_type]).where(date: Time.now.beginning_of_month..Time.now.end_of_month)
    end
  end

  def self.monthly_orders(user, i, issued)
    if(['Admin', 'Internal Sales Manager'].include?(user.account_type))
      where(issued: issued, date: i.month.ago.beginning_of_month..i.month.ago.end_of_month)
    elsif(['Dealer Sales Manager', 'Dealer Salesman'].include?(user.account_type))
      salespeople = user.sales_team.salespeople
      where(salesperson: salespeople, issued: issued, date: i.month.ago.beginning_of_month..i.month.ago.end_of_month)
    end
  end
  
  def export_to_fishbowl
    order = self
    
    begin
      c = Fishbowl::Connection
      c.debug
      settings = Setting.first
      
      c.connect(host: settings.fishbowl_ip, port: settings.fishbowl_port)
      c.login(username: settings.fishbowl_username, password: settings.fishbowl_password)
      
      main_header   = "Flag,SONum,Status,CustomerName,CustomerContact,BillToName,BillToAddress,BillToCity,BillToState,BillToZip,BillToCountry,ShipToName,ShipToAddress,ShipToCity,ShipToState,ShipToZip,ShipToCountry,CarrierName,TaxRateName,Salesman"
      sec_header    = "Flag,SOItemTypeID,ProductNumber,ProductQuantity,UOM,ProductPrice,Taxable,Note,QuickBooksClassName,FulfillmentDate,ShowItem,KitItem"
      cust_header   = "Name,AddressName,AddressContact,AddressType,IsDefault,Address,City,State,Zip,Country,Main,Home,Work,Mobile,Fax,Email"	
      																																																																																																																																																																																																																																																																																																																																																																																																																																																																		
      customer_name   = order.customer.andand.name.andand.gsub(',' ,'')
      formatted_name  = "#{customer.last_name.to_s.gsub(',' ,'')}. #{customer.first_name.to_s.gsub(',' ,'')}"[0..39]
      
      ship_address  = (order.ship_address || order.customer.address).andand.gsub(',' ,'')
      ship_city     = (order.ship_city || order.customer.city).andand.gsub(',' ,'')
      ship_state    = (order.ship_state || order.customer.state).andand.gsub(',' ,'')
      ship_zip      = (order.ship_zip || order.customer.zip).andand.gsub(',' ,'')
      
      customer_info_row = "#{formatted_name},Billing Address,#{customer_name.andand.gsub(',' ,'')},50,true,#{order.customer.address.gsub(',' ,'')},#{order.customer.city.andand.gsub(',' ,'')},#{order.customer.state.andand.gsub(',' ,'')},#{order.customer.zip.andand.gsub(',' ,'')},US,#{order.customer.primary_phone.gsub(',' ,'')},,,,,#{order.customer.email.gsub(',' ,'')}"
      
      customer_row      = "SO,CRM_#{order.id},10,#{formatted_name},#{customer_name.andand.gsub(',' ,'')},#{customer_name.andand.gsub(',' ,'')},#{order.customer.address.gsub(',' ,'')},#{order.customer.city.andand.gsub(',' ,'')},#{order.customer.state.andand.gsub(',' ,'')},#{order.customer.zip.andand.gsub(',' ,'')},US,#{order.customer.name.andand.gsub(',' ,'')},#{ship_address},#{ship_city},#{ship_state},#{ship_zip},US,Will Call,None,#{order.salesperson.andand.rep_name}".delete("\n")
      product_row       = "Item, 10, 88M, 1, ea, 0, TRUE,,Dealer Sales (Barn)"
      
      c.import(:type => 'ImportCustomers', :rows => [cust_header, customer_info_row])
      puts "customer imported"
      c.import(:type => "ImportSalesOrder", :rows => [main_header, sec_header, customer_row, product_row].flatten)
      puts 'true'
      order.update(in_fishbowl: true) 
    rescue StandardError => e
      puts e.message
      puts e.backtrace
      
      puts 'false'
    ensure
      c.close
    end
  end
  
  def csv_export_line(total = nil)
    begin
      prices = JSON.load(self.prices)
      json = JSON.load(self.json_info)

      if(json['data']['options']['size'] == 'Custom')
        width   = json['data']['custom']['size']['width']
        length  = json['data']['custom']['size']['len']
      else
        width = json['data']['options']['size']['width']
        length = json['data']['options']['size']['len']
      end

      internal_order = (self.salesperson.sales_team.name == 'Internal') ? "1" : nil
      dealer_order = dealer_order ? nil : "1"

      discount = prices['discount_total'].gsub(/[$,]/,'').to_f.to_s
      formatted_discount = discount != "0" ? "-" + discount : discount
      
      shipping = json['data']['customer']['shipping']

      [self.date.strftime("%Y"), self.date.strftime("%B"), 1, nil, self.date.strftime("%m/%d/%Y"), self.customer.andand.name, dealer_order, internal_order, 
      self.salesperson.andand.rep_name, width, "X", length, (width.to_i * length.to_i), 
      json['data']['options']['style'], json['data']['options']['feature'], json['data']['options']['build_type'][0].upcase, prices['subtotal_1'].gsub(/[$,]/,''),
      prices['options_subtotal'].gsub(/[$,]/,'').to_f + prices['delivery'].gsub(/[$,]/,'').to_f, formatted_discount, prices['subtotal_4'].gsub(/[$,]/,'').to_f, nil, internal_order, dealer_order, nil, 
      shipping['state'], shipping['county'], shipping['city'], shipping['zip'], nil, nil, 0, json['data']['customer']['sales_method'], json['data']['customer']['advertisement']]  
    rescue Exception => e
      puts e
      nil
    end
  end
  
  def self.export_to_dropbox
    @header = [ 'Year', 'Month', 'Barn', 'Misc', 'Date', 'Name', 'Dlr Sale', 'Inside Sale', 'Rep', 'W', 'X', 'D', 'Sq Foot', 'Model', 'Feature', 
                'P/A', 'Barn Price', 'Options', 'Discounts', 'Total', 'Variance', 'Inside', 'Dealer', 'Total2', 'State', 'County', 'Ship-to City', 
                'Zip', 'Inside Goal', 'Dealer Goal', 'Total Goal', 'Sales Method', 'Advertisement', 'Closed/ Open', 'Barn2', 'Misc2', 'Cancel',
                'Delivery Goal', 'Del Year', 'Del Month', 'Del Date',	'Inv #', 'Subtotal w/ Del', 'Subtotal w/o Del', 'Dwnpymnt Collected', 'Comm. %',
                'Comm. Amnt', 'Coupon or special', 'Manual Adj', 'Final Due', 'Paid', 'Ref#', 'Notes'] 				
    orders = self.where(exported: false, issued: true)

    @lines = orders.map do |order| 
      order.csv_export_line    
    end  
     
    @lines.compact!
    
    csv_data = CSV.generate do|csv|
      csv << @header
      @lines.each {|line| csv << line}
    end    

    client = Dropbox::Client.new(ENV['WEAVER_DROPBOX_TOKEN'])      

    client.upload("/Exports/Export-#{Time.now.strftime("%m-%d-%Y %H_%M")}.csv", csv_data)

    orders.update_all(exported: true) 
  end

  def create_pdf    
    ::Invoice::Generator.new( self ).generate_pdf
  end  

  def save_to_dropbox    
    if(Rails.env.production?)
      client = Dropbox::Client.new(ENV['WEAVER_DROPBOX_TOKEN'])    
      file = client.upload("/Sales Orders/Order #{id}/Invoice_#{id}_#{Date.today.strftime("%m-%e-%y")}.pdf", create_pdf)

      if(self.dropbox_url.nil?)
        metadata = client.create_shared_link_with_settings("/Sales Orders/Order #{self.id}", {"requested_visibility": "public"})
        update(dropbox_url: metadata.url)
      end
    end


  end  
  
  def generate_dropbox_url
    begin
      client = DropboxClient.new(ENV['WEAVER_DROPBOX_TOKEN'])
      session = DropboxOAuth2Session.new(ENV['WEAVER_DROPBOX_TOKEN'], nil)
      response = session.do_get "/shares/auto/#{client.format_path("/Sales Orders/Order #{self.id}")}", {"short_url"=>false}
      Dropbox::parse_response(response)['url']
    rescue
      nil
    end
  end

  def get_coordinates(json)
    
    if(self.change_orders.size > 0)        
      json = JSON.load(self.change_orders.order(:id).last.json_info)
    else
      json = JSON.load(self.json_info)
    end   
        
    response = ::Geocoder.search("#{json['data']['customer']['shipping']['address']} #{json['data']['customer']['shipping']['city']} #{json['data']['customer']['shipping']['state']} #{json['data']['customer']['shipping']['zip']}")
    
    if(!response.empty?)
      self.latitude   = response.first.data['geometry']['location']['lat']
      self.longitude  = response.first.data['geometry']['location']['lng']
    end
  end

  before_save do |record|
    get_coordinates(nil)
  end

  
  def isoft_tag_id
    INFUSIONSOFT_TAG_KEYS[JSON.load(json_info)['data']['options']['style']]
  end
  
  def track_in_infusionsoft?
    (salesperson.sales_team.track_in_infusionsoft || salesperson.track_in_infusionsoft)
  end
  
  belongs_to  :customer
  belongs_to  :salesperson
  belongs_to  :locked_by,       class_name: 'Salesperson'
  belongs_to  :modified_by,     class_name: 'Salesperson'
  belongs_to  :final_approver,  class_name: 'Salesperson'
  
  has_many    :change_orders,   dependent: :destroy
end

