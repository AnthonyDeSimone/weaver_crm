require 'geocoder'

class Customer < ActiveRecord::Base
  validates :name, presence: true
  
  enum lead_status: [ :cold, :lukewarm, :hot ]

  def lead_statuses
    [ :cold, :lukewarm, :hot ]
  end
  
  def self.lead_statuses
    [ :cold, :lukewarm, :hot ]
  end

  has_many    :sales_orders
  belongs_to  :sales_team
  has_many    :customer_comments
  
  def has_quote?
    !SalesOrder.where(customer: self).empty?
  end
  
  def update_infusionsoft(order)
    if(order.track_in_infusionsoft?)
      infusionsoft_email = !email.blank? ? email : self.id.to_s
      
      if(self.infusionsoft_id)
        contact_id = self.infusionsoft_id
      else
        contact_id = Infusionsoft.contact_add_with_dup_check({Email: infusionsoft_email, FirstName: first_name, LastName: last_name}, 'EmailAndName')
        update(infusionsoft_id: contact_id)
      end
      
      quote_date = JSON.load(order.json_info)['data']['extra']['quote_date'].split('/').map(&:to_i)
      quote_date_xmlrpc= XMLRPC::DateTime.new(quote_date[2], quote_date[0], quote_date[1], 0, 0, 0) rescue nil
      
      customer_info = { FirstName: first_name, LastName: last_name,
                        StreetAddress1: address, City: city, State: state, 
                        PostalCode: zip, Country: 'United States',
                        Phone1: primary_phone, Phone2: secondary_phone,
                        Email: email}
                        
      customer_info[:_QuoteDate] = quote_date_xmlrpc if quote_date_xmlrpc
            
      Infusionsoft.contact_update(contact_id, customer_info)
    
      #Tag for shed type
      Infusionsoft.contact_add_to_group(contact_id, order.isoft_tag_id)      
      
      #Tag for sales team
      Infusionsoft.contact_add_to_group(contact_id, order.salesperson.sales_team.isoft_tag_id)   
            
      #Tag for salesperson 
      Infusionsoft.contact_add_to_group(contact_id, order.salesperson.isoft_tag_id)  
      
      if(!order.open)          
        Infusionsoft.contact_remove_from_group(contact_id, 105)            
        Infusionsoft.contact_add_to_group(contact_id, 4686)
      elsif(!order.issued)      
        Infusionsoft.contact_add_to_group(contact_id, 103)    
      else
        Infusionsoft.contact_remove_from_group(contact_id, 103)
        Infusionsoft.contact_remove_from_group(contact_id, 4686)
        
        Infusionsoft.contact_add_to_group(contact_id, 105)
      end
    end
  end
  
  before_save do |record|
    response = ::Geocoder.search("#{record.address} #{record.city} #{record.state} #{record.zip}")
    
    if(!response.empty?)
      self.latitude   = response.first.data['geometry']['location']['lat']
      self.longitude  = response.first.data['geometry']['location']['lng']
    end
  end
end
