require 'pp'

module Fishbowl::Objects
  class SalesOrderItem < BaseObject
    attr_accessor :product_number, :description, :quantity, :item_type
                  
    def self.attributes
      %w{ ProductNumber, Description, Quantity, ItemType}
    end
    
    def initialize(user_xml)
      @xml = Nokogiri::XML.parse(user_xml)
    
      @product_number = @xml.xpath("//ProductNumber").inner_text
      @description    = @xml.xpath("//Description").inner_text
      @quantity       = @xml.xpath("//Quantity").inner_text
      @item_type      = @xml.xpath("//ItemType").inner_text
      self
    end
  end
end
