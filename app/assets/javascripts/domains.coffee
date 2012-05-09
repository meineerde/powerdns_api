$ ->
  toggle_disabled_required = (id, true_if) ->
    input = $("##{id}")
    label = $("label[for=#{id}]")

    if true_if()
      input.prop('disabled', false)
      input.prop('required', true)

      label.prepend('<abbr title="required">*</abbr>')

      label.addClass('required')
      label.parent().addClass('required')
      label.removeClass('optional disabled')
      label.parent().removeClass('optional disabled')
    else
      input.prop('disabled', true)
      input.prop('required', false)

      label.find('abbr').remove()

      label.addClass('optional disabled')
      label.parent().addClass('optional disabled')
      label.removeClass('required')
      label.parent().removeClass('required')

  # update the punycode encoded domain name
  $('#domain_name').keyup ->
    ascii = punycode.toASCII($(this).val())
    $('#domain_name_punycode').text(ascii);

  $('#domain_type').change ->
    self = $(this)
    true_if = ->
      self.val() == "SLAVE"
    toggle_disabled_required('domain_master', true_if)

