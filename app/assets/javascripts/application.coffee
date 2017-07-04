#= require jquery
#= require jquery.turbolinks
#= require rails-ujs
#= require turbolinks
#= require bootstrap-sprockets
#= require icheck
#= require jquery.nicescroll
#= require clipboard
#= require select2
#= require_tree .
#= require_tree ../../../vendor/assets/javascripts/.

init_icheck = () ->
  $('input').iCheck {checkboxClass: 'icheckbox_flat-green', radioClass: 'iradio_flat-green'}

$ ->
  $(document).on('turbolinks:load', init_icheck)
  $(document).on('turbolinks:load', -> new Clipboard('.clipboard-btn'))


$(document).ready ->
  # default toastr config
  toastr.options = {
    "positionClass": "toast-top-center",
    "progressBar": "true",
    "timeOut": "10000"
  }
