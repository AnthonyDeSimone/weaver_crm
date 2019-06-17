require 'pp'

module Fishbowl::Objects
  class SalesOrder < BaseObject
    attr_accessor :items, :note, :created_date, :ship_date, :customer
                  
    def self.attributes
      []
    end
    
    def initialize(user_xml)
      @xml = user_xml
      #parse_attributes

      #@products = @xml.xpath("//Items/SalesOrderItem/ProductNumber").map(&:inner_text)

      @items = []

      @customer     = @xml.xpath("//SalesOrder/CustomerName").inner_text
      @created_date = @xml.xpath("//SalesOrder/CreatedDate").inner_text
      @ship_date    = @xml.xpath("//SalesOrder/FirstShipDate").inner_text  
      @note         = @xml.xpath("//SalesOrder/Note").inner_text
      @xml.xpath("//Items/SalesOrderItem").each do |xml|
        @items << Fishbowl::Objects::SalesOrderItem.new(xml.to_xml)
      end
      
      self
    end
  end
end
