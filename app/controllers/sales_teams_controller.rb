class SalesTeamsController < ApplicationController
  def new
    @sales_team = SalesTeam.new
  end
  
  def create
    @sales_team = SalesTeam.create(params.require(:sales_team).permit(params[:sales_team].keys))
    
    redirect_to sales_teams_url
  end
  
  def index
    @sales_teams = SalesTeam.order(:name)#.paginate(:page => params[:page], :per_page => 15)
  end  
  
  def edit
    @sales_team = SalesTeam.find(params[:id])
  end

  def update
    @sales_team = SalesTeam.find(params[:id])
    
    @sales_team.update(sales_team_params)
    
    flash.now[:success] = "Sales Team Updated"
    
    render 'edit'
  end
  
  
  def deactivate
    @sales_team = SalesTeam.find(params[:id])
    @sales_team.active = false
    @sales_team.save!
  end  
  
  def edit_infusionsoft_settings
    @sales_teams = SalesTeam.where(active: true).order(:name)
  end
  
  def update_infusionsoft_settings
    @sales_teams = SalesTeam.where(active: true).order(:name)

    SalesTeam.where(id: params[:sales_team_ids]).update_all(track_in_infusionsoft: true)
    SalesTeam.where.not(id: params[:sales_team_ids]).update_all(track_in_infusionsoft: false)
   
    Salesperson.where(id: params[:salespeople_ids]).update_all(track_in_infusionsoft: true)
    Salesperson.where.not(id: params[:salespeople_ids]).update_all(track_in_infusionsoft: false)
    
    flash.now[:success] = "Settings updated."
    render 'edit_infusionsoft_settings'
  end
  
  private
  def sales_team_params
    params.require(:sales_team).permit(:name, :business_name, :address, :phone, :fax, :email, :show_company_on_invoice)
  end
end
