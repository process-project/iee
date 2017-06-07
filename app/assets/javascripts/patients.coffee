$ ->
  # Run refresh for computation that is not yet finished
  @refreshComputation = (row, timeout = 1) ->
    setTimeout ->
      $.ajax
        method: 'get'
        url: $(row).data('url')
        cache: false
        success: (data) ->
          newRow = $(data)
          $(row).replaceWith newRow
          if newRow.data('refresh')
            refreshComputation(newRow, 30000)
          else
            location.reload()
    , timeout

  $('tr[data-refresh="true"]').each ->
    refreshComputation(this)

  $('.diff_output').each ->
    $diff = $(this)
    data = $diff.data()
    comparedText = difflib.stringAsLines(data.comparedContent)
    compareToText = difflib.stringAsLines(data.compareToContent)
    sm = new difflib.SequenceMatcher(comparedText, compareToText)

    $diff.append('Result: ' + data.dataType)
    $diff.append(diffview.buildView(
      baseTextLines: comparedText
      newTextLines: compareToText
      opcodes: sm.get_opcodes()
      baseTextName: data.comparedName + ' (' + data.comparedPipeline + ')'
      newTextName: data.compareToName + ' (' + data.compareToPipeline + ')'
      contextSize: 3
      viewType: 0
    ))
