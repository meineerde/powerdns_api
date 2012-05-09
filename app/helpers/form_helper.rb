module FormHelper
  include ActionView::Helpers::UrlHelper

  def confirm_attributes(name, html_options)
    if html_options["data-confirm"]
      confirm_header = html_options.delete("confirm_header")
      confirm_okay = html_options.delete("confirm_okay") || name
      confirm_cancel = html_options.delete("confirm_cancel") || I18n.t('simple_form.buttons.cancel')
      confirm_icons = html_options['button_class']

      html_options["data-confirm-header"] = confirm_header if confirm_header
      html_options["data-confirm-okay"] = confirm_okay if confirm_okay
      html_options["data-confirm-cancel"] = confirm_cancel if confirm_cancel
      html_options["data-confirm-icons"] = confirm_icons
    end
  end

  def button_icons(html_options)
    "<i class=\"#{h html_options.delete('button_class')}\"></i> " if html_options['button_class']
  end

  def button_to(name, options = {}, html_options = {})
    # Almost the same as the upstream method in ActionView::Helpers::UrlHelper
    # Only the last three lines are changed

    html_options = html_options.stringify_keys
    convert_boolean_attributes!(html_options, %w( disabled ))

    method_tag = ''
    if (method = html_options.delete('method')) && %w{put delete}.include?(method.to_s)
      method_tag = tag('input', :type => 'hidden', :name => '_method', :value => method.to_s)
    end

    form_method = method.to_s == 'get' ? 'get' : 'post'
    form_options = html_options.delete('form') || {}
    form_options[:class] ||= html_options.delete('form_class') || 'button_to'

    remote = html_options.delete('remote')

    request_token_tag = ''
    if form_method == 'post' && protect_against_forgery?
      request_token_tag = tag(:input, :type => "hidden", :name => request_forgery_protection_token.to_s, :value => form_authenticity_token)
    end

    url = options.is_a?(String) ? options : self.url_for(options)
    name ||= url

    html_options = convert_options_to_data_attributes(options, html_options)
    html_options.merge!("type" => "submit")

    form_options.merge!(:method => form_method, :action => url)
    form_options.merge!("data-remote" => "true") if remote

    # set conformation attributes and get the icon classes for bootstrap
    confirm_attributes(name, html_options)
    icons = button_icons(html_options)

    # use a button tag instead of input#submit
    "#{tag(:form, form_options, true)}<div>#{method_tag}#{tag("button", html_options, true)}#{icons}#{h(name)}</button>#{request_token_tag}</div></form>".html_safe
  end

  def link_to(*args, &block)
    # Almost the same as the upstream method in ActionView::Helpers::UrlHelper

    if block_given?
      options      = args.first || {}
      html_options = args.second
      link_to(capture(&block), options, html_options)
    else
      name         = args[0]
      options      = args[1] || {}
      html_options = args[2]

      html_options = convert_options_to_data_attributes(options, html_options)
      url = url_for(options)

      # set conformation attributes and get the icon classes for bootstrap
      confirm_attributes(name || url, html_options)
      icons = button_icons(html_options)

      href = html_options['href']
      tag_options = tag_options(html_options)

      href_attr = "href=\"#{ERB::Util.html_escape(url)}\"" unless href
      "<a #{href_attr}#{tag_options}>#{icons}#{ERB::Util.html_escape(name || url)}</a>".html_safe
    end
  end
end