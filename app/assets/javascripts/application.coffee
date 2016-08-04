#= require jquery
#= require jquery.turbolinks
#= require jquery_ujs
#= require turbolinks
#= require bootstrap-sprockets
#= require icheck
#= require jquery.nicescroll
#= require zeroclipboard
#= require_tree .
#= require_tree ../../../vendor/assets/javascripts/.

$(document).ready ->
  $('input').iCheck {checkboxClass: 'icheckbox_flat-green', radioClass: 'iradio_flat-green'}

  # Flash
  if (flash = $(".flash-container")).length > 0
    flash.click -> $(@).fadeOut()
    flash.show()
    setTimeout (-> flash.fadeOut()), 3000
