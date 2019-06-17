class SalespeopleController < ApplicationController
	#before_filter :has_admin_privileges, except: [:new, :index, :edit, :update, :deactivate, :reactivate]
	before_filter :can_create_users#, only: [:new, :index, :edit]
 
  def can_create_users
    authenticate_salesperson!
    
    unless(['Admin', 'Dealer Sales Manager', 'Internal Sales Manager'].include?(current_salesperson.account_type))
      flash[:error] = 'You don\'t have access to that page.'
      redirect_to(:root)
    end
  end   
  
  def index
    @show_search = true
    if(current_salesperson.account_type == 'Admin')
      @users = Salesperson.where(active: true).where.not(id: current_salesperson.id).order(:created_at)#.paginate(:page => params[:page], :per_page => 25)
      @sales_teams = SalesTeam.all
    else
      @users = Salesperson.where(active: true, sales_team: current_salesperson.sales_team).where.not(id: current_salesperson.id)#.paginate(:page => params[:page], :per_page => 25)
      @sales_teams = [current_salesperson.sales_team]
    end
  end
  
  def inactive_index
    @users = Salesperson.where(active: false)#.paginate(:page => params[:page], :per_page => 25)
    @sales_teams = SalesTeam.all 
    render 'index'
  end
  
  
  def edit
    @user = Salesperson.find(params[:id])
  end
  
  def update
    salesperson = Salesperson.find(params[:id])
    salesperson.update(params.require(:salesperson).permit(params[:salesperson].keys))
    salesperson.sales_teams = []
    params[:salesperson]['sales_team_ids'].reject {|id| id.empty?}.each do |id|
      salesperson.sales_teams << SalesTeam.find(id.to_i)
    end
    
    redirect_to salespeople_path
  end
  
  def show_by_team
    @current_sales_team = SalesTeam.find(params[:team_id])
    
    @users = Salesperson.where(sales_team: @current_sales_team, active: true)#.paginate(:page => params[:page], :per_page => 25)
    @sales_teams = SalesTeam.all
    render :index
  end
  
  def deactivate
    @user = Salesperson.find(params[:id])
    @user.active = false
    @user.save!
    
    render nothing: true
  end
  
  def reactivate
    @user = Salesperson.find(params[:id])
    @user.active = true
    @user.save!
    
    render nothing: true
  end  
  
end
