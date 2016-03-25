#= require jquery
#= require jquery.turbolinks
#= require jquery_ujs
#= require turbolinks
#= require bootstrap-sprockets
#= require icheck
#= require_tree .
#= require_tree ../../../vendor/assets/javascripts/.

$(document).ready ->
  $('input').iCheck {checkboxClass: 'icheckbox_flat-green', radioClass: 'iradio_flat-green'}
