class CreateAgencies < ActiveRecord::Migration
  def self.up
    create_table :agencies do |t|
      t.string :name
      t.string :address_1
      t.string :address_2
      t.string :address_3
      t.string :city
      t.string :prov
      t.string :postal
      t.string :phone
      t.string :fax
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :agencies
  end
end
