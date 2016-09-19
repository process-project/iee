#= require jquery
#= require jquery.turbolinks
#= require jquery_ujs
#= require turbolinks
#= require bootstrap-sprockets
#= require icheck
#= require jquery.nicescroll
#= require zeroclipboard
#= require select2
#= require_tree .
#= require_tree ../../../vendor/assets/javascripts/.

init_icheck = () ->
  $('input').iCheck {checkboxClass: 'icheckbox_flat-green', radioClass: 'iradio_flat-green'}

$ ->
  $(document).on('turbolinks:load', init_icheck)

$(document).ready ->
  # Flash
  if (flash = $(".flash-container")).length > 0
    flash.click -> $(@).fadeOut()
    flash.show()
    setTimeout (-> flash.fadeOut()), 10000
