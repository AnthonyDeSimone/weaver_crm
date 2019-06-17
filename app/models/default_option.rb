class DefaultOption < ActiveRecord::Base
  belongs_to :component 
  belongs_to :component_option
  belongs_to :style
end
