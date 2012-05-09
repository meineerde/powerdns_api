class Forms
  class << self
    def [](name)
      forms[name.to_sym]
    end

    def []=(name, form)
      forms[name.to_sym] = form
    end

    def keys
      forms.keys
    end
  protected
    def forms
      @forms ||= {}
    end
  end
end


class BaseForm
  def initialize(*)
    @elements = []
    @generators = {}

    yield self
  end

  def render(html_form, controller)
    render_elements(html_form, controller, "", "\n")
  end

protected
  def self.allowed_sub_element(type)
    klass = type.to_s.classify

    class_eval <<-RUBY, __FILE__, __LINE__
      def #{type}(name, &block)
        name = name.to_sym

        if block_given?
          element(:#{type}, name, #{klass}.new(&block))
        else
          @elements[name]
        end
      end

      def #{type}_before(before, name, &block)
        element_before(:#{type}, before.to_sym, name.to_sym, #{klass}.new(&block))
      end

      def #{type}_after(after, name, &block)
        element_after(:#{type}, after.to_sym, name.to_sym, #{klass}.new(&block))
      end
    RUBY
  end

  def element(type, name, generator)
    @elements << name unless @elements.include? name
    @generators[name] = generator
  end

  def element_after(type, after, name, generator)
    if @elements.include? name
      # Only allow new elements. Existing fields can be changed with #element
      raise ArgumentError.new("#{name} is already registered.")
    end

    after_index = @elements.index(after.to_sym)
    if after_index.nil? || after_index == @elements.length-1
      # Append at the end
      element(name, generator)
    else
      # Perform an insert
      @elements.insert(after_index+1, name)
      @generators[name] = generator
    end
  end

  def element_before(type, before, name, generator)
    before_index = @elements.index(name)

    if @elements.include? name
      # Only allow new elements. Existing fields can be changed with #element
      raise ArgumentError.new("#{name} is already registered.")
    elsif before_index.nil?
      # This method makes only sense if the before element actually exists
      raise ArgumentError.new("#{before} is not registered. I can't insert before it.")
    end

    # Perform an insert
    @elements.insert(before_index, name)
    @generators[name] = generator
  end

  def render_elements(html_form, controller, before, after)
    buffer = ActiveSupport::SafeBuffer.new

    @elements.inject(buffer) do |buffer, name|
      buffer << before
      buffer << @generators[name].render(html_form, controller)
      buffer << after
      buffer
    end
  end
end

class Form < BaseForm
  allowed_sub_element :field
  allowed_sub_element :fieldset
  allowed_sub_element :fields
  allowed_sub_element :table_fields

  def initialize(*form_args)
    @form_args = form_args
    super
  end

  def render(object, controller)
    # ATTENTION: This render is different from all the others as it
    # doesn't expect a form object but a controller instance.
    controller.simple_form_for(object, *@form_args) do |html_form|
      super(html_form, controller)
    end
  end
end

class Field
  def initialize(&generator)
    @generator = generator
  end

  def render(html_form, controller)
    controller.instance_exec(html_form, &@generator)
  end
end

class Fieldset < BaseForm
  allowed_sub_element :field
  allowed_sub_element :fieldset
  allowed_sub_element :fields
  allowed_sub_element :table_fields

  def initialize
    @legend = ""
    super
  end

  def legend(legend = nil)
    @legend = legend if legend
    @legend
  end

  def render(html_form, controller)
    <<-TEMPLATE
      <fieldset>
        <legend>#{ERB::Util.h(@legend)}</legend>
        #{super}
      </fieldset>
    TEMPLATE
  end
end

class Fields < BaseForm
  allowed_sub_element :field
  allowed_sub_element :fieldset

  def for(*args)
    @fields_for = args if args.present?
    @fields_for
  end

  def render(html_form, controller)
    html_form.simple_fields_for(*@fields_for) do |sub_form|
      super(sub_form, controller)
    end
  end
end

class TableFields < BaseForm
  allowed_sub_element :field

  include ActionView::Helpers::TagHelper

  def initialize
    @table_args = {}
    @row_args = {}
  end

  def for(*args)
    @fields_for = args if args.present?
    @fields_for
  end

  def table(args=nil)
    @table_args = args if args.present?
    @table_args
  end

  def row(args=nil)
    @row_args = args if args.present?
    @row_args
  end

  def header(&generator)
    @header = TableHeader.new(&generator)
  end

  def render(html_form, controller)
    content_tag(:table, table_args) do
      buf = ActiveSupport::SafeBuffer.new
      buf << @header.render(html_form, controller)
      buf << html_form.simple_fields_for(*@fields_for) do |sub_form|
        content_tag(:tr, @row_args) do
          render_elements(sub_form, controller, "<td>".html_safe, "</td>".html_safe)
        end
      end
      buf
    end
  end

protected
  # required for the tag helper, but not used by us
  attr_accessor :output_buffer
end

class TableHeader < BaseForm
  allowed_sub_element :field

  def row(args=nil)
    @row_args = args if args.present?
    @row_args
  end

  def render(html_form, controller)
    content_tag(:thead) do
      content_tag(:tr, @row_args) do
        render_elements(html_form, controller, "<th>".html_safe, "</th>".html_safe)
      end
    end
  end

protected
  # required for the tag helper, but not used by us
  attr_accessor :output_buffer
end

Forms[:"domains/show"] = Form.new(:action => :edit) do |form|
  form.field(:name) {|f| f.input :name, :input_html => {:value => SimpleIDN.to_unicode(f.object.name)} }
  form.field(:type) {|f| f.input :type, :collection => Domain::TYPES, :include_blank => false, :hint => t("simple_form.hints.domain.type_html") }
  form.field(:master) {|f| f.input :master, :disabled => !@domain.slave? }
end