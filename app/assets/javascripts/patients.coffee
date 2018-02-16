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

  $('div[data-patient-statistics]').each ->
    $.ajax
      method: 'get'
      url: $(this).data('patient-statistics')
      cache: false
      success: (response) =>
        console.log("response %o", response)
        $(this).find('.patient_stats .count').html(response['count'])
        $(this).find('.patient_stats .count_bottom').html(
          "and <i class='green'>#{response['test']}</i> test entries"
        )
        $(this).find('.patient_site_stats .count').html(
          "#{response['berlin']} | #{response['eindhoven']} | #{response['sheffield']}"
        )
        $(this).find('.patient_site_stats .count_bottom').html(
          "<i class='green'>#{response['no_site']}</i> from unknown site"
        )
        $(this).find('.patient_gender_stats .count').html(
          "#{response['females']} | #{response['males']}"
        )
        $(this).find('.patient_gender_stats .count_bottom').html(
          "<i class='green'>#{response['no_gender']}</i> of unknown gender"
        )
        $(this).find('.patient_state_stats .count').html(
          "#{response['preop']} | #{response['postop']}"
        )
        $(this).find('.patient_state_stats .count_bottom').html(
          "<i class='red'>#{response['no_state']}</i> of unknown state"
        )
