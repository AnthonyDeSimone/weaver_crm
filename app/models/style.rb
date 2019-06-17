class Style < ActiveRecord::Base
  has_many :style_keys
  has_many :style_size_finishes, through: :style_keys
  has_many :default_options
  
  scope :active, -> { where(active: true) }
  
  def name
    display_name || read_attribute(:name)
  end
end
