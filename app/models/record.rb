require 'ip_address_validator'

class Record < ActiveRecord::Base
  TYPES = %w[A AAAA CNAME] # HINFO MX NAPTR NS PTR SOA SPF SRV SSHFP TXT RP]

  belongs_to :domain
  validates :domain, :presence => true

  validates :name, :length => {:maximum => 255}, :allow_blank => true
  validates :type, :length => {:maximum => 10}, :inclusion => TYPES
  validates :content, :length => {:maximum => 4096}
  validates :ttl, :prio, :change_date, :numericality => {:only_integer => true}, :allow_nil => true

  attr_accessible :name, :type, :content, :prio, :ttl

  after_initialize do
    self.type ||= "A"
  end
end