class CreateSupermasters < ActiveRecord::Migration
  def change
    create_table :supermasters, :id => false do |t|
      t.string  :ip, :length => 25, :null => false
      t.string  :nameserver, :length => 255, :null => false
      t.string  :account, :length => 40, :null => false
    end
  end
end
