class AAAA < Record
  validates :content, :presence => true, :ipv6_address => true
end