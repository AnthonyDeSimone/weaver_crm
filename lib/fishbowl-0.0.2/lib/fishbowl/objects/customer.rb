require 'pp'

module Fishbowl::Objects
  class Customer < BaseObject
    attr_accessor :customer_id, :account_id, :status, :def_payment_terms, :def_ship_terms, :tax_rate, :name, :number,
                  :date_created, :date_last_modified, :last_changed_user, :credit_limit, :tax_exempt_number, :note,
                  :active_flag, :accounding_id, :default_salesman, :job_depth, :parent_id, :url, :tax_rate, :main_address,
                  :ship_address, :bill_address
                  
    def self.attributes
      %w{ CustomerID AccountID Status DefPaymentTerms DefShipTerms TaxRate Name Number
          DateCreated DateLastModified LastChangedUser CreditLimit TaxExemptNumber Note
          ActiveFlag AccountingID DefaultSalesman JobDepth ParentID URL}
    end
    
    def initialize(user_xml)
      @xml = user_xml
      parse_attributes

      types       = @xml.xpath("//Addresses/Address/Type").map(&:inner_text)
      number      = @xml.xpath("//Name").first.inner_text      
      name        = @xml.xpath("//Number").map(&:inner_text) 
      attn        = @xml.xpath("//Addresses/Address/Attn").map(&:inner_text)
      street      = @xml.xpath("//Addresses/Address/Street").map(&:inner_text)
      city        = @xml.xpath("//Addresses/Address/City").map(&:inner_text)      
      zip         = @xml.xpath("//Addresses/Address/Zip").map(&:inner_text)
      state       = @xml.xpath("//Addresses/Address/State/Name").map(&:inner_text)
      country     = @xml.xpath("//Addresses/Address/Country/Name").map(&:inner_text)
      country     = @xml.xpath("//Addresses/Address/Country/Name").map(&:inner_text)
      residential = @xml.xpath("//Addresses/Address/Residential").map(&:inner_text)
      
      @tax_rate       = @xml.xpath("//Customer/TaxRate").inner_text
      #Address/Email
      contact_keys    = @xml.xpath("//Addresses/Address/AddressInformationList/AddressInformation/Type").map {|d| k = d.inner_text; k == 'Main' ? 'phone' : k.downcase}
      contact_values  = @xml.xpath("//Addresses/Address/AddressInformationList/AddressInformation/Data").map(&:inner_text)
      
      @addresses = {}
      
      types.each_with_index do |type, i|
        @addresses[type] = {'name' => name[i], 'number' => number,  'attn' => attn[i], 'street' => street[i], 'city' => city[i], 
                            'zip' => zip[i], 'state' => state[i], 'country' => country[i], 'residential' => residential[i] }
        
        @addresses[type].merge! Hash[contact_keys.zip(contact_values)]
      end

      @main_address = @addresses.values.first
      @bill_address = @addresses['Bill To'] || @main_address
      @ship_address = @addresses['Ship To'] || @main_address

      self
    end
  end
end
