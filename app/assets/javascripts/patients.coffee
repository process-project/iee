$ ->
  # Run refresh for computation that is not yet finished
  refreshComputation = (row, timeout = 1) ->
    setTimeout ->
      $.ajax
        method: 'get'
        url: $(row).data('url')
        cache: false
        success: (data) ->
          newRow = $(data)
          $(row).replaceWith newRow
          refreshComputation(newRow, 30000) if newRow.data('refresh')
    , timeout

  $('tr[data-refresh="true"]').each ->
    refreshComputation(this)
