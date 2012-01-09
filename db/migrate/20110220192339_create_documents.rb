class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.string :title
      t.string :filetype
      t.text :description
      t.string :filename
      t.integer :event_id
      t.timestamps
    end
  end

  def self.down
    drop_table :documents
  end
end
