class User < ActiveRecord::Base
  include DeviseInvitable::Inviter

  belongs_to  :sales_team
  enum account_type: [:admin, :internal_sales, :dealer_sales, :internal_sales_manager, :dealer_sales_manager, :engineering, :delivery, :maufacturing]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, 
         :confirmable, :invitable
end
