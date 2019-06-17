class SalesOrderItem < ActiveRecord::Base
  belongs_to  :sales_order

  def corresponding_component
    if(self.component)
      return {component: self.component.id}
    else
      return {component: self.component_option.component.id, component_option: self.component_option.id}
    end
  end
end
