class StyleKey < ActiveRecord::Base
  belongs_to  :style
  belongs_to  :style_size_finish
end
