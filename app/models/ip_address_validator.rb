class IpAddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless IPAddress.valid?(value)
      record.errors.add attribute, :ip_address
    end
  end
end

class Ipv4AddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless IPAddress::IPv4.valid?(value)
      record.errors.add attribute, :ipv4_address, :value => value
    end
  end
end

class Ipv6AddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless IPAddress::IPv6.valid?(value)
      record.errors.add attribute, :ipv6_address, :value => value
    end
  end
end

class DomainNameValidator < ActiveModel::EachValidator
  def initialize(*args, &block)
    # starts with a letter or digit
    # contains only letters, digits and hyphen
    # ends with letter or digit
    # max length is 63 chars
    label = /[A-Za-z0-9-]{1,63}/

    # one or more labels separated by dots
    domain = /#{label}(\.#{label})*\.?/

    # a domain or a single dot (the root zone) or an empty string
    @regex = /^(#{domain}|\.)?$/

    super
  end

  def validate_each(record, attribute, value)
    unless value =~ @regex
      record.errors.add attribute, :domain_name, :value => value
    end
  end
end
