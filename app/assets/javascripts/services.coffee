jQuery ->
  next_id=1
  $('a#add').click ->
    $('a#add').before('<input class="string optional form-control" type="text" style="margin-bottom: 5px" name="service[uri_aliases][]" id="service_'+next_id+'">')
    next_id = next_id + 1
    return
  return