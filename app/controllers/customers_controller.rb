class CustomersController < ActionController::Base
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :null_session
  
 rescue_from ActiveRecord::RecordNotFound, :with => :rescue_not_found

 rescue_from Exception do |exception|
  puts exception.message
  puts exception.backtrace 
  rescue_server_error(exception)
 end
 
  def new
    @customer = Customer.new
    render layout: 'application.html.haml'
  end
  
  def edit
    @customer = Customer.find(params[:id])      
    render layout: 'application.html.haml'
  end
  
  def update
    if(params[:customer]['referer'])
      referer = params[:customer].delete('referer')
    else
      referer = nil
    end
    
    parameters = params.require(:customer).permit(params[:customer].keys)
    parameters.delete('referer')
    parameters[:quote_date] = Date.strptime(parameters[:quote_date], "%m/%d/%Y") rescue nil
    parameters[:callback_date] = Date.strptime(parameters[:callback_date], "%m/%d/%Y") rescue nil
    parameters[:sales_team] = current_salesperson.sales_team
    
    Customer.find(params[:id]).update(parameters) 
    redirect_to customers_path    
  end
  
  def show
    @customer = Customer.find(params[:id])

    render layout: 'application.html.haml'
  end

  def create
    parameters = params.require(:customer).permit(params[:customer].keys)
    
    parameters[:quote_date] = Date.strptime(parameters[:quote_date], "%m/%d/%Y") rescue nil
    parameters[:callback_date] = Date.strptime(parameters[:callback_date], "%m/%d/%Y") rescue nil
    parameters[:sales_team] = current_salesperson.sales_team
      
    @customer = Customer.create(parameters)
    
    redirect_to customers_path
  end

  def opportunities
    user = view_context.current_salesperson    
    
    sales_orders = SalesOrder.joins(:customer, :salesperson).where(issued: false, active: true).where.not(customer_id: nil)

    if(params[:customer_name].present?)
      sales_orders = sales_orders.where("customers.name ilike ?", "%#{params[:customer_name]}%")
    end

    case user.account_type 
      when 'Internal Sales Manager', 'Dealer Sales Manager'
        sales_orders = sales_orders.where(salesperson: Salesperson.where(sales_team: user.sales_team))
        @show_all_teams = true        
      when 'Internal Salesman', 'Dealer Salesman'
        sales_orders = sales_orders.where(salesperson: user)
    end

    @customers = smart_listing_create(:customers, 
                          sales_orders, 
                          partial: 'opportunity_listing')       


    respond_to do |format|
      format.js {render 'index.js', layout: false}
      format.html {render 'opportunities', layout: 'application.html.haml'}
    end 

  end  

  def index
    if(['Admin', 'Delivery' 'Internal Salesman', 'Internal Sales Manager'].include?(view_context.current_salesperson.account_type))
      team  = params[:sales_team].present? ? SalesTeam.find(params[:sales_team]) : SalesTeam.all
      @show_all_teams = true
    else
      team = view_context.current_salesperson.sales_team
    end 

    customers = Customer.where(sales_team: team)

    if(params[:customer_name].present? && params[:customer_name] != 'Customer Name')
      customers = customers.where("name ilike ?", "%#{params[:customer_name]}%")
    end


    smart_listing_create(:customers, 
                          customers, 
                          partial: 'listing')    

    respond_to do |format|
      format.js {render 'index.js', layout: false}
      format.html {render 'index', layout: 'application.html.haml'}
    end 
  end
  
  def search
    puts params
    q = params[:q]
    
    if(q.nil? || q.empty?)
      results = {id: 0, text: 'Add New Customer'}
    else
      customer_search_results  = customers_for_user.where("lower(name) like :q", q: "%#{q.downcase}%")
      results = customer_search_results.map {|c| {id: c.id, text: "#{c.name} - #{c.id}", name: c.name, address: c.address, county: c.county, 
                                                  city: c.city, state: c.state, zip: c.zip, primary_phone: c.primary_phone,
                                                  secondary_phone: c.secondary_phone, email: c.email}}      
    end

    respond_to do |format|
      format.html {render :json => {items: results}, :callback => params['callback']}
      format.json {render :json => {items: results}, :callback => params['callback']}
    end
  end
  
  def hot
    @customers = Customer.where(lead_status: Customer.lead_statuses[:hot]).paginate(:page => params[:page], :per_page => 25); 
    
    render :index, layout: 'application.html.haml'
  end
  
  
  
  protected
  def customers_for_user
    #Restrict customers seen except for admins
    
    if(['Admin', 'Internal Sales Manager', 'Internal Salesman', 'Engineering', 'Shipping', 'Manufacturing'].include?(current_salesperson.account_type)) 
      Customer.all
    else
      Customer.where(sales_team: current_salesperson.sales_team)
    end
  end
  
  def rescue_not_found
    render :template => 'not_found.html.haml', :status => :not_found
  end
  
  def rescue_server_error(exception)
    @exception = exception
    render :template => 'error.html.haml', :status => :error  
  end
end
