class PaymentsController < ApplicationController

  def create
    payment = Payment.new(params[:payment])
    if(payment.process)
      format.html { redirect_to(@order) :notice => "Your payment has been processed }
    end
  end

end
