class SpecialOrderItemsController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  def index
    items = SpecialOrderItem.joins(:sales_order).
                              where(sales_orders: {open: true}).
                              where(required: true, ordered: false)

    @items = smart_listing_create(:outstanding_items, 
                                  items, 
                                  sort_attributes: [[:order_id, 'sales_orders.id'], [:order_delivery_date, 'orders.delivery_date'],[:name, 'name'], [:po_number,'po_number']],
                                  default_sort: {id: "desc"},
                                  partial: 'listing')    

    respond_to do |format|
      
      format.js {render 'index.js', layout: false}
      format.html {render 'index'}
    end
  end
end
