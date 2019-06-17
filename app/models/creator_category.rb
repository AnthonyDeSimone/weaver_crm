class CreatorCategory < ActiveRecord::Base
  has_many :creator_images 

  belongs_to :parent, foreign_key:  'parent_id',
                      class_name:   'CreatorCategoryRel',
                      dependent:    :destroy

  belongs_to :children, foreign_key:  'child_id',
                        class_name:   'CreatorCategoryRel',
                        dependent:    :destroy
end
