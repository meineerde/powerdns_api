# Adapted from https://gist.github.com/1862479
$.rails.allowAction = (element) ->
  message = element.data('confirm')
  return true unless message # nothing to confirm

  header = element.data('confirmHeader')
  cancel = element.data('confirmCancel')
  okay = element.data('confirmOkay')
  icons = element.data('confirmIcons')

  if icons
    okay = "<i class=\"#{icons} icon-white\"></i> " + okay

  # Clone the clicked element (probably a delete link) so we can use it in the dialog box.
  if element.is('button')
    $form = element.closest('form').clone()
    $btn = $form.find('button')
  else
    $btn = element.clone()
    $form = $btn

  $btn
    # We don't want to pop up another confirmation (recursion)
    .removeAttr('data-confirm').removeAttr('data-confirm-header')
    .removeAttr('data-confirm-okay').removeAttr('data-confirm-cancel')
    # We want a button
    .addClass('btn').addClass('btn-danger')
    .removeClass('btn-small').removeClass('btn-mini')
    # We want it to sound confirmy
    .html(okay)

  modal_html = """
    <div class="modal">
      <div class="modal-header">
        <a class="close" data-dismiss="modal">×</a>
        <h3>#{header}</h3>
      </div>
      <div class="modal-body">
        <p>#{message}</p>
      </div>
      <div class="modal-footer">
        <a data-dismiss="modal" class="btn">#{cancel}</a>
      </div>
    </div>
  """
  $modal_html = $(modal_html)
  # Add the new button to the modal box
  $modal_html.find('.modal-footer').append($form)
  # Pop it up and position it in the middle of the page
  $modal_html.modal()
  $modal_html.css('margin-top', ($modal_html.height() / 2 * -1))
  # Focus the action button
  $btn.focus()

  # Prevent the original link from working
  return false

