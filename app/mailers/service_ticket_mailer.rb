class ServiceTicketMailer < ActionMailer::Base
  default from: "service_tickets@weaverbarns.com"
  
  def billing_email(ticket)
    @ticket = ticket

    attachments["service_ticket_#{@ticket.id}.pdf"] = ServiceTicketPdf.new(@ticket, view_context).render   
    
    mail(to: 'mmiller@weaverbarns.com', subject: "Service Ticket #{@ticket.id} Closed") 
  end
end
