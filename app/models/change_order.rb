class ChangeOrder < ActiveRecord::Base 
  belongs_to :sales_order
  belongs_to :salesperson
  
  def export_to_dropbox()    
    prices = JSON.load(self.prices)
    
    self.sales_order.export_to_dropbox(prices['total'])    
  end
end
