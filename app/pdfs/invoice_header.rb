class InvoiceHeader < InvoicePdf
  def initialize(order, json, prices, revision, view, change_order_created_by=nil)
    super(order, json, prices, revision, view, change_order_created_by)
    #create_pdf(order, view)
  end
  
  def create_pdf(order, json, prices, revision, view, created_by, change_order_created_by = nil)
      @order = order
      @revision = revision
      @prices = JSON.load(order.prices)
      font_size 8
      json = JSON.load(order.json_info)
      
      move_up 40
      logo_start = cursor

      repeat(:all) do
        bounding_box([0, logo_start - 15], :width => (bounds.width * 1), height: 150) do
          logo
          move_down 25
          font_size 20
          puts logo_start.inspect
          #move_cursor_to logo_start
          heading = @order.issued ? "Order #{order.id}" : "Quote #{order.id}" 
          heading += "-#{@revision}" if revision
          
          draw_text heading, style: :bold, at: [bounds.width - 120, bounds.height - 30]
          font_size 10
          draw_text business_address[0], at: [bounds.width - 200, bounds.height - 45]
          draw_text business_address[1], at: [bounds.width - 200, bounds.height - 55]
          font_size 8
        end
      end            
  end
end
