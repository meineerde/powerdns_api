class CNAME < Record
  validates :content, :presence => true, :format => {:with => URI::HOST, :message => :hostname}
end