module DomainRepresenter
  include Roar::Representer::JSON::HAL

  property :name
  property :master
  property :type
  property :account

  collection :records, :as => Record, :embedded => true

  link(:self) { domain_url self, :only_path => true }
  link(:records) { domain_records_url self, :only_path => true }
end