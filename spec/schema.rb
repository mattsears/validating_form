class DatabaseSchema < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.column :name, :string, :null => false      
      t.column :email, :string, :null => false
      t.column :phone, :string, :null => false
      t.column :gender, :string, :null => false
    end
  end  
end