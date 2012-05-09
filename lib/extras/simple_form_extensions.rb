module WrappedSubmitButton
  def wrapped_submit_button(*args, &block)
    options = args.extract_options!

    table = " form-actions-table" if options.delete(:table)
    template.content_tag :div, :class => "form-actions #{table}" do
      loading = self.object.new_record? ? I18n.t('simple_form.creating') : I18n.t('simple_form.updating')
      options[:"data-loading-text"] = [loading, options[:"data-loading-text"]].compact
      options[:"data-disable-with"] = [loading, options[:"data-disable-with"]].compact
      options[:class] = ['btn-primary', options[:class]].compact
      args << options
      if cancel = options.delete(:cancel)
        submit(*args, &block) + ' ' + template.link_to(I18n.t('simple_form.buttons.cancel'), cancel, :class => "btn")
      else
        submit(*args, &block)
      end
    end
  end
end
SimpleForm::FormBuilder.send :include, WrappedSubmitButton