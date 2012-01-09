class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string :name
      t.string :address1
      t.string :address2
      t.string :city
      t.string :prov
      t.string :postal
      t.string :phone
      t.string :email
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end
