class CreatorCategoryRelationship < ActiveRecord::Base
  belongs_to  :parent,  :class_name => 'CreatorCategory'
  belongs_to  :child,   :class_name => 'CreatorCategory'
end
