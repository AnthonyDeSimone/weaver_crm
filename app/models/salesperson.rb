class Salesperson < ActiveRecord::Base
  belongs_to  :sales_team
  has_many    :sales_team_connectors
  has_many    :sales_teams, through: :sales_team_connectors
  has_many    :sales_orders
  
  validates :name, presence: true
  validates :account_type, presence: true
  validates :email, presence: true

  scope :active, -> { where(active: true) }
  
  enum account_type: ['Admin', 'Internal Salesman', 'Dealer Salesman', 'Internal Sales Manager', 'Dealer Sales Manager', 'Engineering', 'Shipping', 'Manufacturing']
  
  ISOFT_SALESPERSON_CAT_ID = 22
  
  def account_types 
    ['Admin', 'Internal Salesman', 'Dealer Salesman', 'Internal Sales Manager', 'Dealer Sales Manager', 'Engineering', 'Shipping', 'Manufacturing']
  end
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :invitable, :validate_on_invite => true
         
         
  attr_reader :raw_invitation_token
  
  def all_sales_teams
    [sales_team] + sales_teams 
  end

  def show_production_information?
    ['Admin', 'Shipping'].include?(account_type)
  end

  def show_approval_status?
    account_type == 'Dealer Sales Manager'
  end
  
  def isoft_tag_id
    result = Infusionsoft.data_query('ContactGroup', 1, 0, {GroupName: name}, [:Id, :GroupName])
    
    if result.empty?
      Infusionsoft.data_add('ContactGroup', {GroupName: name, GroupCategoryId: ISOFT_SALESPERSON_CAT_ID})
    else
      result.first['Id']
    end
  end
end

class InvitationsController < Devise::InvitationsController
  def create
    @from    = 'Joe'
    @subject = 'This is a test'
    @content = 'Stuuuff'

    @user = User.invite!(params[:user], current_user) do |u|
      u.skip_invitation = true
    end

    NotificationMailer.invite_message(@user, @from, @subject, @content).deliver
    @user.invitation_sent_at = Time.now.utc # mark invitation as delivered

    if @user.errors.empty?
      flash[:notice] = "successfully sent invite to #{@user.email}"
      respond_with @user, :location => root_path
    else
      render :new
    end
  end
end

class NotificationMailer < ActionMailer::Base
  def invite_message(user, from, subject, content)
    @user = user
    @token = user.raw_invitation_token
    invitation_link = accept_user_invitation_url(:invitation_token => @token)

    mail(:from => from, :bcc => from, :to => @user.email, :subject => subject) do |format|
      content = content.gsub '{{first_name}}', user.first_name
      content = content.gsub '{{last_name}}', user.first_name
      content = content.gsub '{{full_name}}', user.full_name
      content = content.gsub('{{invitation_link}}', invitation_link)
      format.text do
        render :text => content
      end
    end
  end
end
