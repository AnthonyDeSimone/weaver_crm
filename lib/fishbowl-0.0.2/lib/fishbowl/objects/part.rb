module Fishbowl::Objects
  class Part < BaseObject
    attr_accessor :db_id, :num, :description, :upc, :uomid, :active_flag, :vendor

    def self.attributes
      %w{ID Num Description UPC UOMID ActiveFlag Vendor}
    end

    def initialize(xml)
      @xml = xml
      parse_attributes
      self
    end
  end
end
