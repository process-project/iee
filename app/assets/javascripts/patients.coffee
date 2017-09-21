$ ->
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
  $('div[data-patient-details]').each ->
    div = $(this)
    patientUrl = div.data('patient-details')
    console.log("patient id %o", patientUrl)
    $.ajax
      method: 'get'
      url: patientUrl
      cache: false
      success: (response) ->
        console.log("response %o", response)
        console.log("div %o", div)
        div.replaceWith(response)
