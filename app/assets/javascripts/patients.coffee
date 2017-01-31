$ ->
  # Run refresh for computation that is not yet finished
  window.refreshComputation = (row, timeout = 1) ->
    setTimeout ->
      $.ajax
        method: 'get'
        url: $(row).data('url')
        cache: false
        success: (data) ->
          newRow = $(data)
          $(row).replaceWith newRow
          if newRow.data('refresh')
            window.refreshComputation(newRow, 30000)
          else
            location.reload()
    , timeout

  $('tr[data-refresh="true"]').each ->
    window.refreshComputation(this)
