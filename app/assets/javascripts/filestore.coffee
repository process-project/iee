$ ->
  $('img[data-filestore-src]').each ->
    img = $(this)
    filestoreUrl = img.data('filestore-src')
    request = new XMLHttpRequest()
    request.open('GET',filestoreUrl, true)
    request.setRequestHeader('Authorization', 'Bearer ' + $('meta[name=token]')[0].content)
    request.responseType = 'arraybuffer'
    request.onload = () ->
      binary = '';
      bytes = new Uint8Array( this.response );
      len = bytes.byteLength;
      for i in [0...len]
        binary += String.fromCharCode(bytes[i])
      base64 = btoa(binary)
      src = "data:image;base64," + base64
      img.attr('src', src)

    request.send()