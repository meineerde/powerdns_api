require 'ip_address_validator'

class Supermaster < ActiveRecord::Base
  validates :ip, :ip_address => true, :presence => true
  validates :nameserver, :length => {:maximum => 255}, :presence => true
  validates :account, :length => {:maximum => 40}, :allow_nil => true
end