class ServiceTicketsController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  before_action :set_service_ticket, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_salesperson!, except: [:save, :load_ticket]
  
  respond_to :html

  def set_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end
    
  def index  
    @show_completed = params.key?(:show_completed) ? params[:show_completed] == 'true' : false
  
    if(['Dealer Sales Manager', 'Dealer Salesman'].include?(current_salesperson.account_type))
      service_tickets = ServiceTicket.where(completed: @show_completed, salesperson: Salesperson.where(sales_team: current_salesperson.sales_team))   
    else
      service_tickets = ServiceTicket.where(completed: @show_completed)
    end
    if params["service_tickets_smart_listing"] && params["service_tickets_smart_listing"]["page"].blank?
      params["service_tickets_smart_listing"]["page"] = 1 
    end

    smart_listing_create(:service_tickets, 
                          service_tickets.joins(:customer), 
                          sort_attributes: [[:id, 'id'], [:customer_name, 'customers.name'], [:date, 'date'], [:confirmed, 'confirmed'], [:materials_not_in_hand, 'materials_not_in_hand']],
                          partial: 'listing')    
    
    respond_to do |format|
      
      format.js {render 'index.js', layout: false}
      format.html {render 'index'}
    end                              
  end

  def show
    respond_with(@service_ticket)
  end

  def new
    @service_ticket = ServiceTicket.new
    @is_dealer = ['Dealer Sales Manager', 'Dealer Salesman'].include?(current_salesperson.account_type)
 
    render 'new', layout: false
  end

  def edit
    @ticket = ServiceTicket.find(params[:id])
    @is_dealer = ['Dealer Sales Manager', 'Dealer Salesman'].include?(current_salesperson.account_type)
        
    @ticket_load_info = "loadServiceTicket(#{@ticket.id})"
    
    @page_title = 'Edit Sales Order'
    @save_unavailable = @ticket.confirmed
    render :new, layout: false    
  end
  
  def load_ticket
    @ticket = ServiceTicket.find(params[:id])

    render json: @ticket.info, :callback => params['callback']
  end 
  
  def save 
    set_headers

    date = Date.strptime(params['ticket']['date'], "%m/%d/%Y") rescue nil

    #Update or add new Customer######################
    customer_fields       = params['ticket']['customer']
    customer_id           = customer_fields.delete('id')

    new_customer_fields = {}
    
    required_fields = ['name', 'first_name', 'last_name', 'email', 'secondary_email', 'primary_phone', 'secondary_phone', 'address', 'county', 'state', 'city', 'zip']
    customer_fields.each {|k, v| new_customer_fields[k.to_sym] = v if(required_fields.include?(k))}
    
    if(customer_id.nil?)
      new_customer_fields[:sales_team] = (current_salesperson.sales_team rescue SalesTeam.order(:id).first)
      customer = Customer.create(new_customer_fields)
      
      params['ticket']['customer']['id'] = customer.id
    elsif(customer_id == nil)
      customer = nil
    else
      customer = Customer.find(customer_id)

      customer.update(new_customer_fields)
      customer.save
    end
        
    blank_materials = params['ticket']['service_material'].andand.select {|m| m['description'].blank? }.size
    materials_not_in_hand = (params['ticket']['materials_not_yet_ordered'] + params['ticket']['materials_not_yet_arrived']).to_i - blank_materials.to_i
    
    if(params['ticket']['id'])
      @ticket = ServiceTicket.find(params['ticket']['id'])
      
      @ticket.update( info: params.to_json,
                      customer_presence_required: params['ticket']['customer_present_required'],
                      site_visit_required: params['ticket']['site_visit'], salesperson: current_salesperson,
                      notes: params['ticket']['notes'], time_frame: params['ticket']['time_frame'], date: date,
                      materials_not_in_hand: materials_not_in_hand)
    else
      @ticket = ServiceTicket.create( info: params.to_json, customer: customer)
      params['ticket']['id'] = @ticket.id
      @ticket.update( info: params.to_json,
                      customer_presence_required: params['ticket']['customer_present_required'],
                      site_visit_required: params['ticket']['site_visit'], salesperson: current_salesperson,
                      notes: params['ticket']['notes'], time_frame: params['ticket']['time_frame'], date: date,
                      materials_not_in_hand: materials_not_in_hand)      
    end
    
    respond_to do |format|
      format.html {render :json => {ticket: {id: @ticket.id}, customer: {id: @ticket.customer.id}}}
      format.json {render :json => {ticket: {id: @ticket.id}, customer: {id: @ticket.customer.id}}}
    end  
  end
  
  def show
    @ticket = ServiceTicket.find(params[:id])
    
    respond_to do |format|
      format.pdf do
        pdf = ServiceTicketPdf.new(@ticket, view_context).render
        
        send_data pdf, filename: 
        "invoice_#{@ticket.id}.pdf",
        type: "application/pdf"#,
       # disposition: 'attachment'
      end
    end
  end
=begin  
  def create
    begin
      parameters = params.require(:service_ticket).permit(params[:service_ticket].keys)
      parameters[:sales_order] = SalesOrder.find(parameters[:sales_order_id])  
    
      parameters[:salesperson] = view_context.current_salesperson

      parameters[:date] = Date.strptime(parameters[:date], "%m/%d/%Y") rescue nil   
      parameters[:finished] = false  
       
      @service_ticket = ServiceTicket.create(parameters)
      flash[:notice] = 'ServiceTicket was successfully created.'
      flash[:notice] += " It must be approved by corporate." unless ['Delivery', 'Admin'].include?(view_context.current_salesperson.account_type)
    rescue Exception => e
      puts puts puts puts puts e.message
      puts e.backtrace
      flash[:error] = 'ServiceTicket was not created. Make sure a valid sales order was entered.'
      
    end

      redirect_to '/service_tickets'    
  end

  def update
    parameters = params.require(:service_ticket).permit(params[:service_ticket].keys)
    parameters[:sales_order] = SalesOrder.find(parameters[:sales_order])
    parameters[:date] = Date.strptime(parameters[:date], "%m/%d/%Y")# rescue nil   
          
    flash[:notice] = 'ServiceTicket was successfully updated.' if @service_ticket.update(parameters)
    redirect_to service_tickets_path
  end
=end
  def mark_complete
    @service_ticket = ServiceTicket.find(params[:id])
    @service_ticket.update(completed: true)
    
    ServiceTicketMailer.billing_email(@service_ticket).deliver
    
    render nothing: true
  end
  
  def confirm
    @ticket = ServiceTicket.find(params[:id])
    @ticket.confirmed = (params.keys.include? 'confirm')
    @ticket.save  
    #Send email to Mose ServiceTickerMailer.invoice_email(@ticket).deliver  
    
    render nothing: true
  end

  def destroy
    ServiceTicket.find(params[:id]).destroy
    
    render nothing: true
  end

  private
    def set_service_ticket
      @service_ticket = ServiceTicket.find(params[:id])
    end

    def service_ticket_params
      params[:service_ticket]
    end
end
