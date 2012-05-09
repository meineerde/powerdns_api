class AddDomainSlug < ActiveRecord::Migration
  class Domain < ActiveRecord::Base
    def self.inheritance_column
      # Disable STI to not mess with the type column
      nil
    end
  end

  def up
    add_column    :domains, :slug, :string, :null => true
    add_index     :domains, :slug, :unique => true, :name => 'slug_index'

    # set the slug apropriately
    Domain.find_each do |domain|
      domain.update_attribute(:slug, domain.name.gsub('.', '_'))
    end

    change_column :domains, :slug, :string, :null => false
  end

  def down
    remove_index  :domains, :name => :slug_index
    remove_column :domains, :slug
  end
end
