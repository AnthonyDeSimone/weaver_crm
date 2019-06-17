require 'dropbox'

class CustomerMailer < ActionMailer::Base
  default from:         "sales@weaverbarns.com",
          content_type: 'multipart/alternative',
          parts_order:  [ "text/html", "text/enriched", "text/plain", "application/pdf"] 
  
  def invoice_email(order, comments = nil, from_address = 'sales@weaverbarns', use_secondary_email)
    @order = order
    @comments = !(comments.nil? || comments.empty?) ? comments : nil
    
    json = JSON.load @order.json_info
    
    secondary_email = json['data']['customer']['secondary_email'] 
    recipients = order.customer.email
    
    if(!secondary_email.to_s.empty? && use_secondary_email)
      recipients += "," + secondary_email
    end

    pdf = Invoice::Generator.new( SalesOrder.find(@order.id) ).generate_pdf
    
    attachments["#{@order.issued ? 'Invoice' : 'Quote'}_#{@order.id}.pdf"] = pdf       
 
    puts "Sending email"
    mail(to: recipients, subject: "Weaver Barns #{@order.issued ? 'Invoice' : 'Quote'}", from: from_address)
  end
 
  def test_email()
    @url = root_url
    mail(to: 'anthonysdesimone@gmail.com', subject: 'Weaver Barns Order Invoice', from: from_address)
  end
  
  def dropbox_email(order, comments = nil, from_address = 'sales@weaverbarns', use_secondary_email)
    @order = order
    
    json = JSON.load(@order.json_info)
    
    secondary_email = json['data']['customer']['secondary_email'] 
    recipients = order.customer.email
    
    if(!secondary_email.to_s.empty? && use_secondary_email)
      recipients += "," + secondary_email
    end
        
    @comments = !(comments.nil? || comments.empty?) ? comments : nil
    begin
      @url = order.dropbox_url
      mail(to: recipients, subject: 'Weaver Barns Order Details', from: from_address)      
      
      return true
    rescue
      return false
    end
  end  
end
