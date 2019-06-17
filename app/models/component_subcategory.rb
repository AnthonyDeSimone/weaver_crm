class ComponentSubcategory < ActiveRecord::Base
  has_many    :components
  belongs_to  :component_category
  
  accepts_nested_attributes_for :components
end
