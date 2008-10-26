ActiveRecord::Migration.suppress_messages do
  ActiveRecord::Schema.define(:version => 0) do
    create_table :users, :force => true do |t|
       t.column :name, :string, :null => false      
       t.column :email, :string, :null => false
       t.column :phone, :string, :null => false
       t.column :gender, :string, :null => false
     end
  end
end