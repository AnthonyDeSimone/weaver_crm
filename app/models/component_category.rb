class ComponentCategory < ActiveRecord::Base
  has_many :component_subcategories
  
  accepts_nested_attributes_for :component_subcategories
end
