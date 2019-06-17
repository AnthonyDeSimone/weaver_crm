require 'fishbowl'
require 'csv'
require 'dropbox'

class SalesOrdersController < ApplicationController
  include ApplicationHelper
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  skip_before_filter  :verify_authenticity_token
  
  before_filter :authenticate_salesperson!, except: [:save, :load_order]
  #before_filter :is_internal_user, only: [:google_map]

  APP_KEY = '760u1kf8u4cdwcc'
  APP_SECRET = 'zde1gvbq82clcip'

  def new
    @load_order_info = ''

    @page_title = 'New Sales Order'
    @save_unavailable = false
    render layout: false
  end
  
  def change_log
    @order = SalesOrder.includes(:change_orders).find(params[:id])
    
    render 'change_log', layout: false
  end

  def site_ready
    @order = SalesOrder.find(params[:id])
    json = JSON.load(@order.json_info)

    json['data']['extra']['site_ready'] = true
    json['data']['extra']['site_ready_clicked'] = Time.now.strftime("%m/%d/%Y")

    @order.update(json_info: json.to_json)
    @order.update(build_status: :ready_to_process, status: :Site_Ready)

    render nothing: true
  end
  
  def in_use
    @order = SalesOrder.find(params[:id])
    
    if(@order && current_salesperson)
      @order.lock!(current_salesperson)
      
      render nothing: true, status: 200
    else
      render nothing: true, status: 404    
    end
    
  end

  def set_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  def preflight
    set_headers
    render :json => [].to_json, :callback => params['callback']
  end
  
  def change_build_status
    @order = SalesOrder.find(params[:id])
    @order.send("#{params[:status]}!")

    if(params[:status] == 'in_production')
      @order.update(production_order_printed_at: Date.today)
    end

    render nothing: true
  end
  
  def modify_prices
    @order = SalesOrder.find(params[:id])

    if(@order.change_orders.size > 0)
      @json = JSON.load(@order.change_orders.sort_by{|o| o.id}.last.json_info)
    else
      @json = JSON.load(@order.json_info)
    end
    
    @line_items = view_context.sales_order_calculator(@json, :number)[:sidebar_items] 
    
    if(@json['data']['options']['size'] == 'Custom')
      @base_price = @json['data']['custom']['base_price']
    else
      @base_price = @json['data']['base_price']  
    end
  end

  def update_prices
    @order = SalesOrder.find(params[:id])

    if(@order.change_orders.size > 0)
      json_info = JSON.load(@order.change_orders.sort_by{|o| o.id}.last.json_info)
    else
      json_info = JSON.load(@order.json_info)
    end
    
    new_prices = {}
    
    params[:items].each_pair do |id, price|
      new_prices[id.to_i] = price.gsub(/[$,]/, '').to_f
    end    

    if(json_info['data']['options']['size'] == 'Custom')
      json_info['data']['custom']['base_price'] = params[:base_price].to_i
    else
      json_info['data']['base_price'] = params[:base_price].to_i  
    end

    
    
    json_info['data']['additions'].each do |category|
      current_sidebar_items = []
      
      category['subsections'].each do |subcategory|
        next unless subcategory['show']
        
        subcategory['components'].andand.each do |component|
         
          if(new_prices[component['id']])
            component['final_price'] = new_prices[component['id']]
          end
        end
      end
    end
    
    prices = sales_order_recalculate(json_info)  
    json_info['prices'] = prices  


    if(@order.change_orders.size > 0)
      @order.change_orders.sort_by{|o| o.id}.last.update(json_info: json_info.to_json, prices: prices.to_json)
    else
      @order.update(json_info: json_info.to_json, prices: prices.to_json)
    end
    
    flash[:notice] = "Prices for Order #{@order.id} were successfully updated."

    redirect_to "/sales_orders/#{@order.id}/modify_prices"
  end

  def google_map
    @show = params[:show].andand.to_sym || :aos 
    @type = params[:type].andand.to_sym || :order
    
    user = view_context.current_salesperson
    
    if(['Dealer Sales Manager', 'Dealer Salesman'].include?(user.account_type) )
      case @type
        when :order    
          @sales_orders = SalesOrder.where(open: true, issued: true, salesperson: Salesperson.where(sales_team: user.all_sales_teams))
        when :service
          @service_tickets = ServiceTicket.where(confirmed: true, completed: false, salesperson: Salesperson.where(sales_team: user.all_sales_teams))    
        when :all
          @sales_orders = SalesOrder.where(open: true, issued: true, salesperson: Salesperson.where(sales_team: user.all_sales_teams))
          @service_tickets = ServiceTicket.where(confirmed: true, completed: false, salesperson: Salesperson.where(sales_team: user.all_sales_teams))           
      end
    else
      case @type
        when :order
        @sales_orders = SalesOrder.where(open: true, issued: true, build_type: SalesOrder.build_types[@show]) #.where("delivery_date < ?", Date.today + 6.weeks)
        when :service
        @service_tickets = ServiceTicket.where(confirmed: true, completed: false)
        when :all
        @service_tickets = ServiceTicket.where(confirmed: true, completed: false)
        @sales_orders = SalesOrder.where(open: true, issued: true)
      end
      
      if(@type == :order)
        if(@show == :aos)
          @showing = 'AOS Orders'
        else
          @showing = 'Prebuilt Orders'      
        end
      elsif(@type == :service)
        @showing = 'Service Tickets'
      else
        @showing = 'All Orders & Service Tickets'    
      end
    end
    #@sales_orders = SalesOrder.where("delivery_date > ? AND delivery_date < ?", Date.today - 1.day, Date.today + 6.weeks)
  end
  
  def demo_units_orders
    user = view_context.current_salesperson

    if(['Admin', 'Shipping'].include?(user.account_type))
      orders = SalesOrder.where(open: true).where.not(serial_number: nil)

      @users = smart_listing_create(:sales_orders, 
                              orders, 
                              sort_attributes: sort_attributes,
                              default_sort: {id: "desc"},
                              partial: 'demo_listing')

      render 'demo-index', layout: 'application.html.haml' 
    elsif(['Dealer Sales Manager'].include?(user.account_type))
      orders = SalesOrder.where(open: true, salesperson: Salesperson.where(sales_team: user.sales_teams)).where.not(serial_number: nil)
       @users = smart_listing_create(:sales_orders, 
                              orders, 
                              sort_attributes: sort_attributes,
                              default_sort: {id: "desc"},
                              partial: 'demo_limited_listing')

      render 'demo-limited', layout: 'application.html.haml' 
    else
      @sales_orders = SalesOrder.where(open: true, salesperson: user).where.not(serial_number: nil)
       @users = smart_listing_create(:sales_orders, 
                              orders, 
                              sort_attributes: sort_attributes,
                              default_sort: {id: "desc"},
                              partial: 'demo_limited_listing')

      render 'demo-limited', layout: 'application.html.haml' 
    end
  end
  
  def final_approval
    @order = SalesOrder.find(params[:id])
    @order.update(final_approval: true, approved: true, final_approver: view_context.current_salesperson, final_approval_time: Time.now)
    
    flash[:notice] = "Order #{@order.id} final approval submitted."
    
    redirect_to '/sales_orders/final_approval'
  end
  
  def final_approval_index
    if(current_salesperson.can_approve_orders?) 
      orders = SalesOrder.where(final_approval: false, finalized: true).
                          joins({salesperson: :sales_team}, :customer)
#                          where(build_status: SalesOrder.build_statuses.index(:in_production)).
      @users = smart_listing_create(:sales_orders, 
                              orders, 
                              default_sort: {id: "desc"},
                              partial: 'final_listing')

    respond_to do |format|
      
      format.js {render 'new_index.js', layout: false}
      format.html {render 'final_approval_index'}
    end  

    else
      redirect_to '/'
    end
  end

  def activate
    @order = SalesOrder.find(params[:id]).update(active: true)
    
    render nothing: true
  end

  def deactivate
    @order = SalesOrder.find(params[:id]).update(active: false)
    
    render nothing: true
  end
  
  def special_order_form
    @order                = SalesOrder.find(params[:id])    
    @json                 = JSON.load(@order.json_info) 
    @line_items           = view_context.sales_order_calculator(@json, :number)[:sidebar_items]   
    @special_order_items  = JSON.load(@order.special_order_items_array) 
  end
  
  def submit_special_order
    @order              = SalesOrder.find(params[:id])    
    any_ordered         = false
    special_order_items = nil
    
    special_order_items = params[:item_name].map do |index, name|
      ordered = params[:item_ordered].andand[index.to_s] == 'on'
      
      any_ordered = true if ordered
      
      {name: name, ordered: ordered, note: params[:item_note].andand[index.to_s], po_num: params[:item_po].andand[index.to_s]}
    end
    
    @order.update(special_order_items_array: special_order_items.to_json)
    
    if(any_ordered && !@order.production_order_created)
      @order.update(production_order_created: true) 
      flash[:info] = "Order #{@order.id} special order information was updated, and the order was locked."
    else
      flash[:info] = "Order #{@order.id} special order information was updated."
    end
    
    redirect_to "/sales_orders"
  end
  
  def get_notes
    sales_order = SalesOrder.find(params[:id])

    if(sales_order.change_orders.size > 0)        
      json = JSON.load(sales_order.change_orders.order(:id).last.json_info)
    else
      json = JSON.load(sales_order.json_info)
    end   
  
    notes = json['data']['extra']['additional_notes'].gsub("\n", "<br>").html_safe
    notes = "No additional notes for this order." if notes == ''
    render html: notes
  end
  
  def get_warnings
    @warnings = JSON.load(SalesOrder.find(params[:id]).json_info)['data']['warnings'].values.flatten
    render 'warnings', layout: false
  end
  
  def push_to_fishbowl
    SalesOrder.find(params[:id]).delay.export_to_fishbowl
    
    render nothing: true 
  end
      
  def final_approval_form
    @order  = SalesOrder.find(params[:id])    
    @json   = JSON.load(@order.json_info)
    @prices = JSON.load(@order.prices)
    
    @line_items = view_context.sales_order_calculator(@json, :number)[:sidebar_items]   
       
    if(@json['data']['options']['size'] == 'Custom')
      @width   = @json['data']['custom']['size']['width']
      @length  = @json['data']['custom']['size']['len']
    else
      @width   = @json['data']['options']['size']['width']
      @length  = @json['data']['options']['size']['len']
    end
    
    @feature = @json['data']['options']['feature']
    @feature = @json['data']['custom']['feature'] if(@feature == 'Custom')    

    @style    = @json['data']['options']['style']
    @style    = @json['data']['custom']['structure_name'] if(@style == 'Custom')       
  end
 
  def render_index(issued:, active:, open:, title:, order_type:, other_params: {}, partial: nil)
    user    = current_salesperson
    @open   = open
    @issued = issued    
    @active = active    
    @title  = title 

    orders = SalesOrder.where(open: open, serial_number: nil, active: active, issued: issued).
                        where(other_params).
                        joins(:salesperson).
                        joins("left outer join customers on sales_orders.customer_id = customers.id")


    partial ||= "sales_orders/listing"

    if(['Admin', 'Shipping'].exclude?(user.account_type))
      orders = orders.where(salesperson: Salesperson.where(sales_team: ([user.sales_team] + user.sales_teams)))  
    end

    #Hack to deal with weird placeholder text bug
    if(params[:filter].present? && params[:filter] != 'Customer Name or Order #')
      orders = orders.where("lower(customers.name) like ? or sales_orders.id = ?", "%#{params[:filter].downcase}%", params[:filter].to_i)
    end 

    @users = smart_listing_create(:sales_orders, 
                                  orders, 
                                  sort_attributes: sort_attributes,
                                  default_sort: {id: "desc"},
                                  partial: partial)
    
    respond_to do |format|
      
      format.js {render 'new_index.js', layout: false}
      format.html {render 'new_index'}
    end  
  end
  
  def index
    @status = params[:status] || 'all'
    
    if(@status == 'approved')
      other_params = {final_approval: true}
    elsif(@status == 'not_approved')
      other_params = {final_approval: false}
    elsif(@status != 'all')
      other_params = {status: SalesOrder.statuses[@status]}
    end 

    render_index(issued: true, open: true, active: true, title: 'Open Orders', order_type: :open, other_params: other_params)
  end
  
  def production_complete
    SalesOrder.find(params[:id]).update(build_status: :completed)
    
    render nothing: true
  end

  def prebuilt_status
    @build_status = params[:build_status] || "unavailable"
    
    other_params = {build_type: SalesOrder.build_types[:prebuilt]}

    if(@build_status != 'all')
      build_status = SalesOrder.build_statuses.index(@build_status.to_sym)
      other_params.merge!(build_status: build_status, final_approval: true)
    end

    render_index(issued: true, open: true, active: true, order_type: :open, title: 'Prebuilt Status', 
                  other_params: other_params)        
  end

  def aos_status
    @build_status = params[:build_status] || "unavailable"

    other_params = {build_type: SalesOrder.build_types[:aos]}

    if(@build_status != 'all')
      build_status = SalesOrder.build_statuses.index(@build_status.to_sym)
      other_params.merge!(build_status: build_status, final_approval: true)
    end    
    
    render_index(issued: true, open: true, active: true, order_type: :open, title: 'AOS Status', 
                  other_params: other_params)        
  end


  def quote_index
    render_index(issued: false, open: true, active: true, title: 'Quotes', order_type: :open)
  end
  
  def sales_orders_by_dealer  

    if(params[:salesperson_id].present?)
      other_params = {salesperson_id: params[:salesperson_id]}
    end

    render_index(open: true, issued: true, active: true, order_type: :open, title: 'Orders by Dealer', other_params: other_params, partial: 'listing_by_team')
  end

  def closed_index
    @closed = true
    render_index(issued: true, open: false, active: true, title: 'Closed Orders', order_type: :closed)
  end
 
  def inactive_index
    render_index(open: true, issued: false, active: false, title: 'Inactive Orders', order_type: :inactive)
  end
    
  def follow_ups
    @sales_order = SalesOrder.find(params[:id])
    @sales_order.follow_ups = params[:follow_ups]
    @sales_order.save
    
    render nothing: true
  end
  
  def confirm
    SalesOrder.find(params[:id]).confirm(params.keys.include?('confirm'))
    
    render nothing: true
  end
  
  def close
    order = SalesOrder.find(params[:id])
    order.update(open: false)
    order.customer.update_infusionsoft order
    
    render nothing: true    
  end

  def open
    order = SalesOrder.find(params[:id])
    order.update(open: true)
    order.customer.update_infusionsoft order
    
    render nothing: true    
  end

  def finalize
    SalesOrder.find(params[:id]).update(production_order_created: true)    
    
    render nothing: true    
  end

  def unfinalize
    SalesOrder.find(params[:id]).update(production_order_created: false)    

    render nothing: true    
  end
  
  def save_to_dropbox(id)    
    begin
      if(Rails.env.production?)
        client = Dropbox::Client.new(ENV['WEAVER_DROPBOX_TOKEN'])    
        file = client.upload("/Sales Orders/Order #{id}/Invoice_#{id}_#{Date.today.strftime("%m-%e-%y")}.pdf", create_pdf(id))
      end
    rescue

    end
  end
 
  def create_pdf(id)    
    ::Invoice::Generator.new( SalesOrder.find(id) ).generate_pdf
  end
  
  def comparison
    @order = SalesOrder.find( params[:id] )

    send_data ComparisonPdf.new(@order, JSON.load(@order.json_info), JSON.load(@order.prices), nil, view_context).render
  end

  
  def show
    respond_to do |format|
      format.pdf do
        pdf = create_pdf(params[:id])
        
        send_data pdf, filename: 
        "invoice_#{params[:id]}.pdf",
        type: "application/pdf",
        disposition: 'attachment'
      end
      
      format.html do
        @sales_orders = SalesOrder.where(id: params[:id]).paginate(:page => params[:page], :per_page => 25)
        #@order_type = :open #if @sales_orders.first.open == true
        @search_results = true
        @issued = @sales_orders.first.issued
        @order_type = @sales_orders.first.open ? :open : :closed
        @open = @sales_orders.first.open
        @active = @sales_orders.first.active
        render :index
      end
    end
  end
 
  def production_order
    respond_to do |format|
      format.pdf do
        @order = SalesOrder.find(params[:id])
                
        if(@order.build_type == 'prebuilt')
          @order.update(build_status: :in_production)
        end
        
        if(@order.change_orders.size > 0)
          @json = @order.change_orders.sort_by{|o| o.id}.last.json_info
        else
          @json = @order.json_info
        end
      
        pdf = ProductionOrderPdf.new(@order, @json, view_context)
        send_data pdf.render, filename: 
        "Proudction Order #{@order.id}.pdf",
        type: "application/pdf",
        :disposition => 'inline'
      end
    end
  end 
  
  def general_search
    @status = params[:status] || 'all'
    
    issued      = [true, false]
    open_status = [true, false]

    if(@status == 'approved')
      other_params = {final_approval: true}
    elsif(@status == 'not_approved')
      other_params = {final_approval: false}
    elsif(@status == 'quote') 
      issued = false 
    elsif(@status == 'closed') 
      open_status = false       
    elsif(@status != 'all')
      open_status = true
      other_params = {status: SalesOrder.statuses[@status]}
    end

    render_index(issued: issued, active:[true, false], open: open_status, title: 'General Search', order_type:nil, other_params: other_params, partial: nil)
  end
  
  def search
    search_params = ActiveSupport::HashWithIndifferentAccess.new(params)
    search_params.delete("controller")
    search_params.delete("action")
    query = search_params.delete("filter")
    user = current_salesperson
    
    order_search_params = search_params.dup
    customer_search_params = search_params.dup

    order_search_params[:id] = query

    if(order_search_params["build_status"])
        order_search_params[:build_status] = SalesOrder.build_statuses.index(order_search_params["build_status"].to_sym)
    end
    
    if(['Dealer Salesman', 'Dealer Sales Manager'].include?(user.account_type)) 
      sales_search_results     = SalesOrder.where(order_search_params)
                                    .where(salesperson: Salesperson.where(sales_team: ([user.sales_team] + user.sales_teams))) 
                                    .first rescue nil
      
      customer_search_params[:customer] = Customer.where("lower(name) like ?", "%#{query.downcase}%")
      customer_search_results  = SalesOrder.where(customer_search_params)
                                      .where(salesperson: Salesperson.where(sales_team: ([user.sales_team] + user.sales_teams))) 
    else
      sales_search_results     = SalesOrder.where(order_search_params)
                                            .first rescue nil
      
      customer_search_params[:customer] = Customer.where("lower(name) like ?", "%#{query.downcase}%")
      customer_search_results  = SalesOrder.where(customer_search_params)    
    end
    
    (customer_search_results << sales_search_results).reject{|o| o.andand.customer.nil?} #.map {|o| {id: o.id, text: "#{o.customer.name} - Order #{o.id}"}}
  
    # respond_to do |format|
    #   format.html {render json: {items: @results}}
    #   format.json {render json: {items: @results}}
    # end
  end
  
  def test_email
    CustomerMailer.invoice_email(SalesOrder.first, params[:body]).deliver
  end
  
  def mail_invoice
    @order = SalesOrder.find(params[:id])
 
     if(!@order.customer.email.nil? && !@order.customer.email.empty?)
      if(CustomerMailer.invoice_email(@order, params[:comments], view_context.current_salesperson.email, params[:include_secondary_email] == "true").deliver)
      #  flash[:notice] = "Invoice was sent to #{@order.customer.email}."
      else
       # flash[:error] = "There was a problem sending the email."
      end
    else
    # flash[:error] = "No email address could be found for this customer."     
    end
        
    render json: true
  end

  def mail_dropbox
    @order = SalesOrder.find(params[:id])
    
    email = @order.customer.email
    
    if(!email.nil? && !email.empty?)
      if(CustomerMailer.dropbox_email(@order, params[:comments], view_context.current_salesperson.email, params[:include_secondary_email] == "true").deliver)
        #flash[:notice] = "Dropbox link was sent to #{@order.customer.email}."
      else
        #flash[:error] = "There was a problem sending the email."
      end
    else
        # flash[:error] = "No email address could be found for this customer."     
    end
    
    render json: true
  end

  def load_customer
    @order = SalesOrder.where(id: params[:id]).first
    json = JSON.load(@order.json_info)['data']['customer']
    render json: json, :callback => params['callback']

  end 

  def load_order
    @order = SalesOrder.where(id: params[:id]).first

    if(@order.change_orders.size > 0)
      json = JSON.load(@order.change_orders.sort_by{|o| o.id}.last.json_info)['data']
    else
      json = JSON.load(@order.json_info)['data']
    end

    json['sales_data'] = {salesperson: {id: @order.salesperson.id, name: @order.salesperson.name}}

    render json: json, :callback => params['callback']
  end
  
  def copy
    old_order = SalesOrder.find(params[:id]) 
    
    if(!old_order.issued)
      new_order = old_order.dup
      new_order.modified_by = view_context.current_salesperson
      new_order.save
      json = JSON.load(new_order.json_info)
      json['data']['order_id'] = new_order.id
      new_order.json_info = json.to_json
      new_order.save
      
      save_to_dropbox(new_order.id)

      redirect_to edit_sales_order_path(new_order)      
    else
      redirect_to sales_orders_path
    end
  end
  
  def fishbowl_finalize
    SalesOrder.find(params[:id]).update(finalized_in_fishbowl: true)
    
    render nothing: true  
  end
  
  def set_last_contact_date
    @order = SalesOrder.find(params[:id])
     
    date = Date.strptime(params[:date], "%m/%d/%Y") rescue nil
    
    @order.update(last_contact_date: date) if date
    
    render nothing: true
  end
    
  def set_callback_date
    @customer = SalesOrder.find(params[:id]).customer
     
    date = Date.strptime(params[:date], "%m/%d/%Y") rescue nil
    
    @customer.update(callback_date: date) if date
    
    render nothing: true
  end
      
  def save
    set_headers

    prices = params[:data]['prices']
    site_ready_date = Date.strptime(params[:data]['extra']['site_ready_date'], "%m/%d/%Y") rescue nil
    delivery_date = Date.strptime(params[:data]['extra']['delivery_date'], "%m/%d/%Y") rescue nil
    purchase_date = Date.strptime(params[:data]['extra']['purchase_date'], "%m/%d/%Y") rescue nil
    quote_date = Date.strptime(params[:data]['extra']['quote_date'], "%m/%d/%Y") rescue nil
    outstanding_special_order = params[:data]['special_order'].select {|e| e['required'] && !e['ordered']}.size rescue 0
    estimated_time = params[:data]['extra']['estimated_time']
    
    confirmed = !!params[:data]['extra']['confirmed']
    
    if(confirmed)
      if(delivery_date)
        status = :scheduled
      else
        status = :live
      end    
    end

    serial_number = params[:data]['extra']['serial_number']
    serial_number = nil if serial_number == ""

    #Update or add new Customer######################
    customer_fields       = params[:data]['customer']
    customer_id           = customer_fields.delete('id')
    customer_lead_status  = Customer.lead_statuses[customer_fields.delete('status').to_i]
    customer_fields.delete('text')
    new_customer_fields = {}
    
    required_fields = ['name', 'first_name', 'last_name', 'email', 'secondary_email', 'primary_phone', 'secondary_phone', 'address', 'county', 'state', 'city', 'zip']
    customer_fields.each {|k, v| new_customer_fields[k.to_sym] = v if(required_fields.include?(k))}
    new_customer_fields[:lead_status] = customer_lead_status
    puts params[:data]['customer']
    
    if(customer_id == 0)
      new_customer_fields[:sales_team] = (current_salesperson.sales_team rescue SalesTeam.order(:id).first)
      customer = Customer.create(new_customer_fields)
    elsif(customer_id == nil)
      customer = nil
    else
      customer = Customer.find(customer_id)

      customer.update(new_customer_fields)
      customer.save
    end

    puts "CUSTOMER DONE"    


    crew = params[:data][:crew]
    
    params[:data]['customer']['id'] = customer.id if customer
       
    if(params[:data]['extra']['load_complete']) 
      status = :Load_Complete
    elsif(params[:data]['extra']['scheduled']) 
      status = :Scheduled
    elsif(params[:data]['extra']['working_on_site']) 
      status = :Working_On_Site
    elsif(params[:data]['extra']['site_ready']) 
      status = :Site_Ready
    elsif(confirmed)
      status = :Live
    else
     status = :Quote   
    end

                
    if(params[:data]['order_id']) #Existing order
      @order = SalesOrder.find(params[:data]['order_id'])

      if(!@order.issued) #Just a quote - so any changes go directly to the order itself
        if(params[:data]['extra']['site_ready'] && params[:data]['options']['build_type'].downcase == 'prebuilt' && @order.build_status == 'unavailable')
          @order.update(build_status: :ready_to_process)
        end
        
        customer.delay.update_infusionsoft(@order) if customer.persisted?
        
        @order.update(customer: customer, 
                      json_info: {data: params[:data]}.to_json, 
                      prices: prices.to_json, 
                      image_string: params[:data]['base64'], 
                      delivery_date: delivery_date,
                      site_ready_date: site_ready_date,
                      estimated_time: estimated_time,
                      issued: confirmed,
                      status: status,
                      serial_number: serial_number,
                      ship_address: (params[:data]['shipping']['shipping']['address'] rescue nil),
                      ship_city: (params[:data]['shipping']['shipping']['city'] rescue nil),
                      ship_zip: (params[:data]['shipping']['shipping']['zip'] rescue nil),
                      ship_state: (params[:data]['shipping']['shipping']['state'] rescue nil),
                      ship_county: (params[:data]['shipping']['shipping']['county'] rescue nil),
                      notes: params[:data]['extra']['notes'],
                      crew: params[:data]['extra']['crew'],
                      site_ready: params[:data]['extra']['site_ready'],
                      working_on_site: params[:data]['extra']['working_on_site'],
                      scheduled: params[:data]['extra']['scheduled'],
                      load_complete: params[:data]['extra']['load_complete'],                     
                      build_type: params[:data]['options']['build_type'].downcase.to_sym,
                      modified_by: view_context.current_salesperson,
                      status: status,
                      outstanding_special_order: outstanding_special_order,
                      finalized: params[:data]['extra']['order_finalized']
                      )
        
        @order.update(date: purchase_date) if purchase_date
        @order.update(optional_quote_date: quote_date) if quote_date
      else
      
        revisions = {}
        
        recent_prices = @order.change_orders.empty? ? @order.prices : @order.change_orders.sort_by {|o| o.id}.last.prices
        
        #If new items were added create a sales order revision to track the change
        if(params[:data]['revisions'].andand['additions'] && !params[:data]['revisions']['additions'].empty?)      
          if(!@order.change_orders.empty?)
            previous_json = JSON.load(@order.change_orders.sort_by {|o| o.id}.last.json_info)         
          else
            previous_json = JSON.load(@order.json_info)
          end
          
          revision_info = calculate_revisions(sales_order_calculator(previous_json, :money)[:sidebar_items], sales_order_calculator(params, :money)[:sidebar_items])
          
          #Don't save as a change order if we somehow ended up with 0 quantities
          revision_info.reject! {|e| e['quantity'] == 0}
          
          if(!revision_info.empty? || prices.to_json != recent_prices)
            change_order  = ChangeOrder.create(json_info: {data: params[:data]}.to_json,
                                        prices: prices.to_json,
                                        salesperson: current_salesperson,
                                        image_string: params[:data]['base64']) 
           
            change_order.update(revisions: revision_info.to_json)
                                              
            @order.change_orders << change_order
          end
        end
        
        if(!@order.change_orders.empty?)
          @order.change_orders.sort_by {|o| o.id}.last.update(json_info: {data: params[:data]}.to_json, prices: prices.to_json)
          @order.delay.save_to_dropbox
        else
          @order.update(json_info: {data: params[:data]}.to_json, prices: prices.to_json)
          @order.delay.save_to_dropbox
        end

        if(params[:data]['extra']['site_ready'] && @order.build_status == 'unavailable')
          @order.update(build_status: :ready_to_process)
        end
        
        json_info = JSON.load(@order.json_info)
        
        json_info['data']['extra'] = params[:data]['extra']
                   
        @order.update(customer: customer, 
                      json_info: json_info.to_json,
                      delivery_date: delivery_date,
                      site_ready_date: site_ready_date,
                      estimated_time: estimated_time,
                      issued: confirmed,
                      status: status,
                      serial_number: serial_number,
                      ship_address: (params[:data]['shipping']['shipping']['address'] rescue nil),
                      ship_city: (params[:data]['shipping']['shipping']['city'] rescue nil),
                      ship_zip: (params[:data]['shipping']['shipping']['zip'] rescue nil),
                      ship_state: (params[:data]['shipping']['shipping']['state'] rescue nil),
                      ship_county: (params[:data]['shipping']['shipping']['county'] rescue nil),
                      notes: params[:data]['extra']['notes'],
                      crew: params[:data]['extra']['crew'],
                      site_ready: params[:data]['extra']['site_ready'],
                      working_on_site: params[:data]['extra']['working_on_site'],
                      scheduled: params[:data]['extra']['scheduled'],
                      load_complete: params[:data]['extra']['load_complete'],                     
                      build_type: params[:data]['options']['build_type'].downcase.to_sym,
                      modified_by: view_context.current_salesperson,
                      status: status,
                      outstanding_special_order: outstanding_special_order,
                      finalized: params[:data]['extra']['order_finalized'])

        @order.update(date: purchase_date) if purchase_date
                                
      end
    else #Brand new order
      puts "NEW ORDER"


      if(params[:data]['extra']['site_ready'])
        build_status = :ready_to_process
      else
        build_status = :unavailable
      end
      
      @order = SalesOrder.create( salesperson: current_salesperson, 
                                  customer: customer, 
                                  json_info: {data: params[:data]}.to_json, 
                                  prices: prices.to_json, 
                                  image_string: params[:data]['base64'],                                   
                                  delivery_date: delivery_date,
                                  site_ready_date: site_ready_date,
                                  date: (purchase_date || Time.now),                                  
                                  estimated_time: estimated_time,
                                  issued: confirmed,
                                  status: status,
                                  serial_number: serial_number,
                                  ship_address: (params[:data]['customer']['shipping']['address'] rescue nil),
                                  ship_city: (params[:data]['customer']['shipping']['city'] rescue nil),
                                  ship_zip: (params[:data]['customer']['shipping']['zip'] rescue nil),
                                  ship_state: (params[:data]['customer']['shipping']['state'] rescue nil),
                                  ship_county: (params[:data]['customer']['shipping']['county'] rescue nil),
                                  notes: params[:data]['extra']['notes'],                                  
                                  crew: params[:data]['extra']['crew'],
                                  site_ready: params[:data]['extra']['site_ready'],
                                  working_on_site: params[:data]['extra']['working_on_site'],
                                  scheduled: params[:data]['extra']['scheduled'],
                                  load_complete: params[:data]['extra']['load_complete'],                                     
                                  build_type: params[:data]['options']['build_type'].downcase.to_sym,
                                  approved: (current_salesperson.sales_team.name == 'Internal'),
                                  status: status,
                                  last_contact_date: Date.today,
                                  build_status: build_status,
                                  optional_quote_date: quote_date,
                                  outstanding_special_order: outstanding_special_order,
                                  finalized: params[:data]['extra']['order_finalized']) 
          
          @order.update(date: purchase_date) if purchase_date

          customer.delay.update_infusionsoft(@order) if customer.persisted?
puts "ORDER CREATED"              
          
                                          
        # begin
        #   client = Dropbox::Client.new(ENV['WEAVER_DROPBOX_TOKEN'])
        #   client.create_folder("/Apps/Weaver Barns CRM/Sales Orders/Order #{@order.id}") 
        # rescue
        # end
        
        @order.delay.save_to_dropbox
    end
    
    respond_to do |format|
      format.html {render :json => {order_id: @order.id, customer_id: @order.customer.andand.id, issued: @order.issued}}
      format.json {render :json => {order_id: @order.id, customer_id: @order.customer.andand.id, issued: @order.issued}}
    end
  end
  
  def edit
    @order = SalesOrder.where(id: params[:id]).first
    @order.update_lock_status!
    
    if(@order.unlocked? || @order.locked_by == current_salesperson)   
      @order.lock!(current_salesperson)
      @order_load_info = "loadOrder(#{@order.id})"
      
      @page_title = 'Edit Sales Order'
      @save_unavailable = (@order.final_approval && !['Admin', 'Shipping'].include?(view_context.current_salesperson.account_type)) || 
                          !@order.open || 
                          (@order.in_production? && !['Admin', 'Shipping'].include?(view_context.current_salesperson.account_type))
      render :new, layout: false
    else
      if(@order.locked_by == current_salesperson)
        flash[:error] = "You are currently editing order #{@order.id} in another browser session. Please continue editing it there."   
      else
        flash[:error] = "Order #{@order.id} is currently being edited by #{@order.locked_by.name}"
      end
      
      if request.env["HTTP_REFERER"].present?
        redirect_to :back
      else
        redirect_to '/'
      end
    end
  end
  
  def confirmation
   @order = SalesOrder.find(params[:id]) 
   
   flash[:info] = "Order #{@order.id} was successfully created.".html_safe
   
   if(['Dealer Salesman', 'Dealer Sales Manager'].include?(view_context.current_salesperson.account_type))
    flash[:info] += " It must be approved by corporate."
   end
   
   render :confirmation
  end
  
  def approve
    @order = SalesOrder.find(params[:id]) 
    @order.update(approved: true)

    render nothing: true    
  end

  def unapprove
    @order = SalesOrder.find(params[:id]) 
    @order.update(approved: false)
    puts @order.approved
    render nothing: true
  end
  
  def destroy
    SalesOrder.find(params[:id]).destroy
    
    render nothing: true
  end
  
  def recent
    co_orders = ChangeOrder.where("approved_1 = false or approved_2 = false").pluck(:sales_order_id)

    orders = SalesOrder.select("sales_orders.*, CASE WHEN id IN (#{co_orders.join(',')}) THEN 6 ELSE status END as fake_status").
                        where(issued: true).
                        where("approved_1 = false or approved_2 = false or id IN (#{co_orders.join(',')})")

    @users = smart_listing_create(:sales_orders, 
                                  orders, 
                                  default_sort: {id: "desc"},
                                  partial: "sales_orders/recent_listing")    
    respond_to do |format|      
      format.js {render 'new_index.js', layout: false}
      format.html {render 'recent-index'}
    end

  end
  
  def double_approval
    event = params[:type].constantize.find(params[:id]).update(params[:approver].to_sym => (params[:approved] == 'true'))
    puts "#{params[:type].constantize}.find(#{params[:id]}).update(#{params[:approver].to_sym} => #{(params[:approved] == true)})"
    render json: true
  end
  
  def fishbowl
    orders = SalesOrder.where(issued: true, finalized_in_fishbowl: false).joins(:customer)
    smart_listing_create(:sales_orders, 
                          orders, 
                          default_sort: {id: "desc"},
                          partial: 'fishbowl_listing')

    respond_to do |format|
      format.js {render 'new_index.js', layout: false}
      format.html {render 'fishbowl-index'}
    end  
  end
  
  def push_to_dropbox
    SalesOrder.delay.export_to_dropbox
    render text: 'done'
  end
  
  def export_to_dropbox
    @header = [ 'Year', 'Month', 'Barn', 'Misc', 'Date', 'Name', 'Dlr', 'Sale', 'Inside Sale', 'Rep', 'W', 'X', 'D', 'Sq Foot', 'Model', 'Feature', 
                'P/A', 'Barn Price', 'Options', 'Discounts', 'Total', 'Variance', 'Inside', 'Dealer', 'Total2', 'State', 'County', 'Ship-to City', 
                'Zip', 'Inside Goal', 'Dealer Goal', 'Total Goal', 'Sales Method', 'Advertisement', 'Closed/ Open', 'Barn2', 'Misc2', 'Cancel',
                'Delivery Goal', 'Del Year', 'Del Month', 'Del Date',	'Inv #', 'Subtotal w/ Del', 'Subtotal w/o Del', 'Dwnpymnt Collected', 'Comm. %',
                'Comm. Amnt', 'Coupon or special', 'Manual Adj', 'Final Due', 'Paid', 'Ref#', 'Notes'] 				
    
    orders = SalesOrder.where(exported: false)
    
    @lines = orders.map do |order|
      begin
        prices = JSON.load(order.prices)
        json = JSON.load(order.json_info)

        puts order.id
        if(json['data']['options']['style'] == 'Timber Lodge')
          width   = json['data']['custom']['size']['width']
          length  = json['data']['custom']['size']['len']
        else
          width = json['data']['options']['size']['width']
          length = json['data']['options']['size']['len']
        end
        
        [order.created_at.andand.strftime("%Y"), order.created_at.strftime("%B"), nil, nil, order.created_at.strftime("%m/%d/%Y"), order.customer.name, nil, nil, nil, 
        "#{order.salesperson.andand.sales_team.andand.name} (#{order.salesperson.andand.name})", width, "X", length, (width.to_i * length.to_i), 
        json['data']['options']['style'], json['data']['options']['feature'], json['data']['options']['build_type'][0].upcase, prices['subtotal_1'],
        prices['options_subtotal'], prices['discount_total'], prices['total'], nil, nil, nil, nil, order.ship_state, order.ship_county, 
        order.ship_city, order.ship_zip, order['customer']['sales_method'], order['customer']['advertisement']]
      rescue Exception => e
        puts e.message
        puts e.backtrace
        nil
      end
    end  
    @lines.compact!
    
    csv_data = CSV.generate do|csv|
      csv << @header
      @lines.each {|line| csv << line}
    end    

    client = Dropbox::Client.new(ENV['WEAVER_DROPBOX_TOKEN'])      
    client.upload("/Weaver Barns/Exports/Export-#{Time.now.strftime("%m-%d-%Y")}.csv", csv_data)
    
    orders.update(exported: true)
    
    respond_to do |format|
      format.html
      format.csv {send_data csv_data}
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
  end

  private 
  def sort_attributes
    [
      [:customer_name, "customers.name", "sales_orders.id"],
      [:id, 'id'],
      [:final_approval, 'final_approval'],
      [:status, 'status', "sales_orders.id"],
      [:date, 'date', "sales_orders.id"],
      [:delivery_date, 'delivery_date', "sales_orders.id"],
      [:salesman, 'salespeople.name', "sales_orders.id"],
      [:oustanding, 'outstanding_special_order', "sales_orders.id"],
      [:production_printed, 'production_order_printed_at', "sales_orders.id"],
      [:last_modified, 'modified_by_id', "sales_orders.id"],
      [:site_ready_clicked, 'site_ready_clicked', "sales_orders.id"],
      [:last_contact_date, 'last_contact_date', "sales_orders.id"],
      [:callback_date, 'callback_date', "sales_orders.id"]
    ]
  end
end  
