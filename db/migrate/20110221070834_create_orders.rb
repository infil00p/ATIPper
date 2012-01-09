class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.string :tx_id
      t.integer :user_id
      t.decimal :amount
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
