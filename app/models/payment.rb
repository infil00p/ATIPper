# This is my attempt at keeping this PCI Complaint
# We don't save ANY Credit Card info, and we keep track of the IDs
# Despite the fuckery, we will probably launch with PayPal, but offer others as soon as we can afford it

class Payment 
  attr_accessor :cc, :month, :year, :fname, :lname, :cvv


  #Since we aren't actually using ActiveRecord, we don't get this for free
  def initialize(params)
    self.cc = params[:cc]
    self.month = params[:month]
    self.year = params[:year]
    self.fname = params[:fname]
    self.lname = params[:lname]
    self.cvv params[:cvv]
  end

  def process
    order = Order.find(self.order_id)
    # Create a new credit card object with the variables in memory
    credit_card = ActiveMerchant::Billing::CreditCard.new(
      :number     => self.cc,
      :month      => self.month,
      :year       => self.year,
      :first_name => self.fname,
      :last_name  => self.lname,
      :verification_value  => self.cvv
    ) 

    if credit_card.valid?
      # Create a gateway object to the TrustCommerce service
      gateway = ActiveMerchant::Billing::TrustCommerceGateway.new(
        :login    => 'TestMerchant',
        :password => 'password'
      )

      # Authorize for $10 dollars (1000 cents)
      response = gateway.authorize(1000, credit_card)

      if response.success?
        # Capture the money
        gateway.capture(1000, response.authorization)
        order.status = "processed"
        order.save        
      else
        raise StandardError, response.message
      end
    end
  
  end

end
