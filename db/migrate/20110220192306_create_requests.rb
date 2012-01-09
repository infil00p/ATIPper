class CreateRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.string :title
      t.string :language
      t.integer :agency_id
      t.integer :order_id
      t.text :description
      t.string :status
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :requests
  end
end
