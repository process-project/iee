$(document).on 'turbolinks:load', ->
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

  $('div[data-project-details]').each ->
    div = $(this)
    projectUrl = div.data('project-details')
    console.log("project id %o", projectUrl)
    $.ajax
      method: 'get'
      url: projectUrl
      cache: false
      success: (response) ->
        console.log("response %o", response)
        console.log("div %o", div)
        div.replaceWith(response)

  $('div[data-project-statistics]').each ->
    $.ajax
      method: 'get'
      url: $(this).data('project-statistics')
      cache: false
      success: (response) =>
        console.log("response %o", response)
        $(this).find('.project_stats .count').html(response['count'])
        $(this).find('.project_stats .count_bottom').html(
          "and <i class='green'>#{response['test']}</i> test entries"
        )
        $(this).find('.project_site_stats .count').html(
          "#{response['berlin']} | #{response['eindhoven']} | #{response['sheffield']}"
        )
        $(this).find('.project_site_stats .count_bottom').html(
          "<i class='green'>#{response['no_site']}</i> from unknown site"
        )
        $(this).find('.project_gender_stats .count').html(
          "#{response['females']} | #{response['males']}"
        )
        $(this).find('.project_gender_stats .count_bottom').html(
          "<i class='green'>#{response['no_gender']}</i> of unknown gender"
        )
        $(this).find('.project_disease_stats .count').html(
          "#{response['aortic']} | #{response['mitral']}"
        )
        $(this).find('.project_disease_stats .count_bottom').html(
          "<i class='green'>#{response['no_diagnosis']}</i> with unknown diagnosis"
        )
        $(this).find('.project_state_stats .count').html(
          "#{response['preop']} | #{response['postop']}"
        )
        $(this).find('.project_state_stats .count_bottom').html(
          "<i class='red'>#{response['no_state']}</i> of unknown state"
        )
