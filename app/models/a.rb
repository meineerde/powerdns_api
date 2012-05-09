class A < Record
  validates :content, :presence => true, :ipv4_address => true
end