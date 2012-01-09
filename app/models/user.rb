class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  has_many :requests
  has_many :orders
  has_many :addresses
  has_many :events, :through => :requests
  has_one :user

  after_create :create_order

  def is_admin?
    true
  end

  # There should only be one pending order
  def current_order
    pending = self.orders.where(:status => 'PENDING')
    pending.first
  end

  def create_order
    Order.create(:user => self)
  end

end
