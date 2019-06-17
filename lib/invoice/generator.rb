require 'combine_pdf'

module Invoice
  class Generator
    def initialize(order)
      @order = order
    end
    
    def view_context
      ActionView::Base.new
    end
    
    def generate_pdf
      if(JSON.load(@order.json_info)['data']['options']['style'] == 'Custom')
        if(@order.change_orders.size > 0)
          revision = @order.change_orders.size          
          @json = @order.change_orders.last.json_info
        else
          @json = @order.json_info
          revision = nil
        end        
      
        pdf = CombinePDF.new   
        
           
        header = InvoiceHeader.new(@order, @order.json_info, @order.prices, nil, view_context)
        header = CombinePDF.parse(header.render).pages[0]
                  
        #Add revisions in, most recent first
        revision_count = @order.change_orders.count
        
        @order.change_orders.sort_by{|o| o.id}.reverse.each_with_index do |change_order, index|  
          @json = change_order.json_info
          @prices = change_order.prices

          header = CombinePDF.parse(InvoiceHeader.new(@order, @json, @prices, revision_count - index, view_context).render).pages[0]
          
          pdf << CombinePDF.parse(CustomInvoicePdf.new(@order, @json, @prices, revision_count - index, view_context, change_order.salesperson).render)
          #second_half = CombinePDF.new("app/pdfs/Custom Form.pdf")
          #second_half.pages.each {|page| page << header}
          #pdf << second_half
        end                     
        
        #Add the original
        pdf << CombinePDF.parse(CustomInvoicePdf.new(@order, @order.json_info, @order.prices, nil, view_context).render)
        # second_half = CombinePDF.new("app/pdfs/Custom Form.pdf")
        # second_half.pages.each {|page| page << header}
        # pdf << second_half        

        pdf = pdf.to_pdf
      else
        
        pdf = CombinePDF.new          


        #Add revisions in, most recent first
        revision_count = @order.change_orders.count
                
        @order.change_orders.sort_by{|o| o.id}.reverse.each_with_index do |change_order, index|   
          @json = change_order.json_info
          @prices = change_order.prices
          
          pdf << CombinePDF.parse(InvoicePdf.new(@order, @json, @prices, revision_count - index, view_context, change_order.salesperson).render )
        end 
        
        #Add the original
        pdf << CombinePDF.parse(InvoicePdf.new(@order, @order.json_info, @order.prices, nil, view_context).render )        

        #Add the comparison sheet if this is a quote
        json = JSON.load(@order.json_info)

        custom_style = json['data']['options']['style'] == 'Custom' 
        custom_size = json['data']['options']['size'] == 'Custom'
        style       = json['data']['options']['style']

        if(!@order.issued? && !custom_style && !custom_size && Style.where(pavillion: true).pluck(:name).exclude?(style) && !Style.find_by_name(style).do_not_compare?)
          pdf << CombinePDF.parse( ComparisonPdf.new(@order, JSON.load(@order.json_info), JSON.load(@order.prices), nil, view_context).render )
        end

        pdf = pdf.to_pdf          
      end
      
      return pdf
    end
  end
end
