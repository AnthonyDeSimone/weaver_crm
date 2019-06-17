class SalesTeam < ActiveRecord::Base
  has_many :salespeople
  has_many :customers
  
  ISOFT_SALES_TEAM_CAT_ID = 20
  
  def isoft_tag_id
    result = Infusionsoft.data_query('ContactGroup', 1, 0, {GroupName: name}, [:Id, :GroupName])
    
    if result.empty?
      Infusionsoft.data_add('ContactGroup', {GroupName: name, GroupCategoryId: ISOFT_SALES_TEAM_CAT_ID})
    else
      result.first['Id']
    end
  end  
end
