class Order < ActiveRecord::Base
  has_many :requests
  belongs_to :user
end
