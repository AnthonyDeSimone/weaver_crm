class Salespeople::InvitationsController < DeviseController
  prepend_before_filter :authenticate_inviter!, :only => [:new, :create]
  prepend_before_filter :has_invitations_left?, :only => [:create]
  prepend_before_filter :require_no_authentication, :only => [:edit, :update, :destroy]
  prepend_before_filter :resource_from_invitation_token, :only => [:edit, :destroy]
  helper_method :after_sign_in_path_for

  # GET /resource/invitation/new
  def new
    self.resource = resource_class.new
    
    case current_salesperson.account_type
      when 'Admin'
        render :new     
      when 'Dealer Sales Manager', 'Internal Sales Manager'
        render :limited_new    
    end
  end

  # POST /resource/invitation
 def create
    parameters = params.require(:salesperson).permit(params[:salesperson].keys)


    if(['Internal Salesman', 'Internal Sales Manager', 'Admin'].include?(parameters[:account_type]))
      parameters[:sales_team] = SalesTeam.where(name: 'Internal').first  
    elsif(['Engineering', 'Manufacturing', 'Delivery'].include?(parameters[:account_type]))
      parameters[:sales_team] = nil
    else
      parameters[:sales_team] = (SalesTeam.find(parameters[:sales_team].to_i) rescue view_context.current_salesperson.sales_team)
    end
     
    salesperson = Salesperson.create(parameters) 
     
    if(salesperson.valid?)
      flash[:success] = "New user created." 
      redirect_to '/salespeople'   
    else    
      flash[:error] = salesperson.errors.full_messages.uniq.to_sentence 
      redirect_to '/salespeople'
    end
 end
=begin 
    self.resource = invite_resource
    
    parameters = params.require(:salesperson).permit(params[:salesperson].keys)


    if(['Internal Salesman', 'Internal Sales Manager', 'Admin'].include?(parameters[:account_type]))
      parameters[:sales_team] = SalesTeam.where(name: 'Internal').first  
    elsif(['Engineering', 'Manufacturing', 'Delivery'].include?(parameters[:account_type]))
      parameters[:sales_team] = nil
    else
      parameters[:sales_team] = (SalesTeam.find(parameters[:sales_team].to_i) rescue view_context.current_salesperson.sales_team)
    end

    resource.update(parameters)
    puts resource.inspect
    resource_invited = resource.errors.empty?

    if(resource.errors.empty?)
      puts puts puts "NO ERRROOOOOOOOOOOOOOOOOOOOOOOORS"
      resource.invite!
    else
      puts puts puts "EERRRRRRRRRRRRRROOOOOOOOOORS"
      puts resource.errors.inspect
    end

    yield resource if block_given?

    if resource_invited
      if is_flashing_format? && self.resource.invitation_sent_at
        set_flash_message :notice, :send_instructions, :email => self.resource.email
      end
      respond_with resource, :location => salespeople_path #after_invite_path_for(current_inviter)
    else
      respond_with_navigational(resource) { render :new }
    end
  end  
 
=begin
  def create
    self.resource = invite_resource
    
    parameters = params.require(:salesperson).permit(params[:salesperson].keys)
    user = view_context.current_salesperson

    if(user.account_type == 'Dealer Sales Manager')
      parameters[:sales_team] = user.sales_team.id
    end

    

    if(['Internal Salesman', 'Internal Sales Manager', 'Admin'].include?(parameters[:account_type]))
      parameters[:sales_team] = SalesTeam.where(name: 'Internal').first   
    elsif(['Delivery', 'Engineering', 'Manufacturing'].include?(parameters[:account_type]))
      parameters[:sales_team] = nil        
    else
      if(user.account_type == 'Dealer Sales Manager')
        parameters[:sales_team] = SalesTeam.find(user.sales_team.id)
      else
        parameters[:sales_team] = SalesTeam.find(parameters[:sales_team].to_i) 
      end
    end

    resource.update(parameters)
    
    resource_invited = resource.errors.empty?
    puts puts puts puts puts puts puts "HEEEEEEEEEERE"
    puts resource.errors.inspect

    Salesperson.invite!(email: resource.email)

    yield resource if block_given?
    
    if resource_invited
      if is_flashing_format? && self.resource.invitation_sent_at
        set_flash_message :notice, :send_instructions, :email => self.resource.email
      end
      respond_with resource, :location => salespeople_path #after_invite_path_for(current_inviter)
    else     
      respond_with_navigational(resource) {     
        case current_salesperson.account_type
          when 'Admin'
            render :new     
          when 'Dealer Sales Manager', 'Internal Sales Manager'
            render :limited_new    
        end 
      }
    end
  end
=end
  # GET /resource/invitation/accept?invitation_token=abcdef
  def edit
    resource.invitation_token = params[:invitation_token]
    render :edit
  end

  # PUT /resource/invitation
  def update
    self.resource = accept_resource
    invitation_accepted = resource.errors.empty?

    yield resource if block_given?

    if invitation_accepted
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message :notice, flash_message if is_flashing_format?
      sign_in(resource_name, resource)
      respond_with resource, :location => after_accept_path_for(resource)
    else
      respond_with_navigational(resource){ render :edit }
    end
  end

  # GET /resource/invitation/remove?invitation_token=abcdef
  def destroy
    resource.destroy
    set_flash_message :notice, :invitation_removed if is_flashing_format?
    redirect_to after_sign_out_path_for(resource_name)
  end

  protected

  def invite_resource(&block) 
    resource_class.invite!(invite_params, current_inviter, &block)
  end

  def accept_resource
    resource_class.accept_invitation!(update_resource_params)
  end

  def current_inviter
    authenticate_inviter!
  end

  def has_invitations_left?
    unless current_inviter.nil? || current_inviter.has_invitations_left?
      self.resource = resource_class.new
      set_flash_message :alert, :no_invitations_remaining if is_flashing_format?
      respond_with_navigational(resource) { render :new }
    end
  end

  def resource_from_invitation_token
    unless params[:invitation_token] && self.resource = resource_class.find_by_invitation_token(params[:invitation_token], true)
      set_flash_message(:alert, :invitation_token_invalid) if is_flashing_format?
      redirect_to after_sign_out_path_for(resource_name)
    end
  end

  def invite_params
    devise_parameter_sanitizer.sanitize(:invite)
  end

  def update_resource_params
    devise_parameter_sanitizer.sanitize(:accept_invitation)
  end

end
