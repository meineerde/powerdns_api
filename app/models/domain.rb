require 'ip_address_validator'

class Domain < ActiveRecord::Base
  extend FriendlyId

  TYPES = %w[MASTER SLAVE NATIVE]

  has_many :records, :dependent => :delete_all

  # FIXME: this should check for a domain name, not a host name
  validates :name, :length => {:maximum => 255}, :domain_name => true, :presence => true
  validates :name, :slug, :presence => true, :uniqueness => true
  validates :master, :length => {:maximum => 128}, :allow_nil => true
  validates :type, :presence => true, :inclusion => TYPES
  validates :account, :length => {:maximum => 40}

  validates :last_check, :notified_serial, :numericality => {:only_integer => true}, :allow_nil => true

  validates :master, :presence => true, :ip_address => true, :if => :slave?

  attr_accessible :name, :master, :type, :account, :last_check, :serial
  accepts_nested_attributes_for :records, :allow_destroy => true
  attr_accessible :records_attributes

  after_initialize do
    self.type ||= "NATIVE"
    self.records.build if new_record?
  end
  after_create :create_soa_record

  before_validation do
    # save the domain name in ASCII punycode format
    self.name = SimpleIDN.to_ascii(self.name)
  end
  friendly_id :name, :use => :slugged

  TYPES.each do |type|
    define_method("#{type.downcase}?"){ self.type == type }
  end

  def status_label
    namespace = "activerecord.attributes.#{self.class.model_name.underscore}.status_label"

    "#{namespace}.okay"
  end

  def status_type
    :success
  end

protected

  def normalize_friendly_id(id)
    id.gsub('.', '_')
  end

  def create_soa_record
    return if slave?

    soa self.soa.build(

    )

  end


  class <<self
    def inheritance_column
      # Disable STI to not mess with the type column
      nil
    end
  end
end