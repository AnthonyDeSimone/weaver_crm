class ReportsController < ApplicationController
  before_filter :has_admin_privileges, only: [:index]
  
  def index
    aos_orders = SalesOrder.this_months_orders(current_salesperson, :aos)
    pb_orders = SalesOrder.this_months_orders(current_salesperson, :prebuilt)
                                       
    @aos_sales_order_total  = aos_orders.inject(0)  {|sum, order| sum + JSON.load(order.prices).andand['total'].andand.gsub(/\$/, '').to_f}                                                                                                                                            
    @pb_sales_order_total   = pb_orders.inject(0)   {|sum, order| sum + JSON.load(order.prices).andand['total'].andand.gsub(/\$/, '').to_f}
    
    @current_month = Date::MONTHNAMES[Time.now.month]
    
    current_month_index = Time.now.month
    @outstanding_by_month = 11.downto(0).map do |i|
      orders = SalesOrder.monthly_orders(current_salesperson, i, false) 
      total = orders.inject(0)  {|sum, order| sum + JSON.load(order.prices).andand['total'].to_f}  
      
      {month: Date::MONTHNAMES[i.month.ago.month], total: total}
    end  
    
    @sales_by_month = 11.downto(0).map do |i|
      orders = SalesOrder.monthly_orders(current_salesperson, i, true) 
      total = orders.inject(0)  {|sum, order| sum + JSON.load(order.prices).andand['total'].to_s.gsub(/\$/, '').to_f}  
      
      {month: Date::MONTHNAMES[i.month.ago.month], total: total}
    end  
  end

  def dashboard
    user = view_context.current_salesperson
    
    sales_orders = SalesOrder.where(customer: Customer.where(callback_date: Date.today.beginning_of_week..Date.today.end_of_week)).where(issued: false)
  
    case user.account_type 
      when 'Engineering', 'Manufacturing'
        @customers = []
      when 'Admin', 'Shipping'
        @customers = sales_orders.map(&:customer)
      when 'Internal Sales Manager', 'Dealer Sales Manager'
        @customers = sales_orders.where(salesperson: Salesperson.where(sales_team: user.sales_team)).map(&:customer)
      when 'Internal Salesman', 'Dealer Salesman'
        @customers = SalesOrder.where(salesperson: user).map(&:customer)
    end

    @customers = @customers.to_a.compact
    @customers.uniq!
    
    #render 'dashboard', layout: false
  end
end
