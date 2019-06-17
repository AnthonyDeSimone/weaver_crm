class KeyComponentPair < ActiveRecord::Base
  belongs_to  :style_size_finish
  belongs_to  :component
end
