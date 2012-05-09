class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string  :name, :null => false
      t.string  :master, :limit => 128, :null => true
      t.integer :last_check, :null => true
      t.string  :type, :limit => 6, :null => false
      t.integer :notified_serial, :null => true
      t.string  :account, :limit => 40, :null => true
    end

    change_table :domains do |t|
      t.index   :name, :unique => true, :name => 'name_index'
    end
  end
end
