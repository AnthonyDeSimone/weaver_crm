class SalesTeamConnector < ActiveRecord::Base
  belongs_to :salesperson
  belongs_to :sales_team
end
