class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.references :domain, :null => true
      t.string  :name, :null => true
      t.string  :type, :length => 10, :null => true
      t.string  :content, :length => 4096, :null => true
      t.integer :ttl, :null => true
      t.integer :prio, :null => true
      t.integer :change_date, :null => true
    end

    change_table :records do |t|
      t.foreign_key :domain, :dependent => :delete

      t.index   :name, :name => 'rec_name_index'
      t.index   [:name, :type], :name => 'nametype_index'
      t.index   :domain_id, :name => 'domain_id'
    end
  end
end
