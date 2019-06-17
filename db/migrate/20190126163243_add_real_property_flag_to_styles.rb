class AddRealPropertyFlagToStyles < ActiveRecord::Migration
  def change
    add_column :styles, :real_property, :boolean, default: false

    Style.last(4).each {|s| s.update(real_property: true)}
  end
end
