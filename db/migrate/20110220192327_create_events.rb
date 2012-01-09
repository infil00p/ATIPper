class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.text :description
      t.integer :request_id
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
