 $ ->
  isComputation = ->
    document.getElementById("pipeline") != null

  if isComputation()
    fixedNumberLength = (num, length) ->
      r = '' + num
      while r.length < length
        r = '0' + r
      r

    tick = ->
      $('td[data-computation-start]').each ->
        cell = $(this)
        start = Date.parse(cell.data('computation-start'))
        diff = Math.floor((new Date() - start)/1000)

        hours = Math.floor(diff / 3600)
        minutes = Math.floor(diff / 60) % 60
        seconds = diff % 60

        cell.text(fixedNumberLength(hours, 2) + 'h ' +
                  fixedNumberLength(minutes, 2) + 'm ' +
                  fixedNumberLength(seconds, 2) + 's')

      setTimeout(tick, 1000) if isComputation()

    tick()
