require 'roar/representer/xml'

class ApplicationController < ActionController::Base
  protect_from_forgery

  #before_filter :authenticate_user!
  before_filter :sanitize_limit

  responders Roar::Rails::Responder
  responders :flash, :http_cache

  include Roar::Rails::ControllerAdditions

protected
  class_attribute :_includeable, :instance_writer => false
  self._includeable ||= []

  def self.includeable(*args)
    self._includeable |= args.collect(&:to_sym)
  end

  def respond_with(*args, &block)
    options = args.extract_options!
    unless options.has_key?(:except)
      options[:except] = begin
        excluded = self._includeable
        # Get an array of elements to not include into the API response
        if included = params[:include]
          included = included.respond_to?(:collect) ? included : included.to_s.split(",")
          excluded -= included.collect(&:to_sym)
        end
        excluded
      end
    end

    super(*(args << options), &block)
  end

  # Make sure the limit is a positive integer <= 100
  def sanitize_limit
    return unless limit = params[:limit]
    if limit.to_i.to_s != limit.to_s || limit.to_i < 1
      params.delete(:limit)
    elsif limit.to_i > 100
      params[:limit] = "100"
    end
    nil
  end
end
