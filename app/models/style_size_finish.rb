class StyleSizeFinish < ActiveRecord::Base
  has_many    :style_keys

  has_many    :key_component_pairs
  has_many    :components, through: :key_component_pairs
  
  def feature
    display_feature || read_attribute(:name)
  end  
end
