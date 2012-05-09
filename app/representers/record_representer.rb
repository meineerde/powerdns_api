module RecordRepresenter
  include Roar::Representer::JSON::HAL

  property :name
  property :type
  property :content
  property :ttl
  property :prio

  link(:self) { domain_record_url self.domain, self, :only_path => true }
  link(:domain) { domain_url self.domain, :only_path => true }
end