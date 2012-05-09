Forms[:"domains/show"] = Form.new(:action => :edit) do |form|
  form.field(:name) {|f| f.input :name, :input_html => {:value => SimpleIDN.to_unicode(f.object.name)} }
  form.field(:name) {|f| f.input :type, :collection => Domain::TYPES, :include_blank => false, :hint => t("simple_form.hints.domain.type_html") }
end