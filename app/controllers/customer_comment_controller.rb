class CustomerCommentController < ApplicationController
  def new
    @comment = Comment.new
  end

  def create
    @comment = CustomerComment.create(comment: params[:text])
    Customer.find(params[:customer_id]).customer_comments << @comment

   render partial: 'create'
  end
  
  def destroy
    CustomerComment.find(params[:id]).destroy
    
    render nothing: true
  end
  
  def index
  
  end

  def show

  end
end
