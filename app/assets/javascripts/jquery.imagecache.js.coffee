$.fn.extend
  imagecachify: ->
    @.find('img').imagecache()

  imagecache: ->
    cache = @imagecache.cache || (@imagecache.cache = {})
    @.each (i, img)=>
      console.log [img.width, img.height]
      $img = $(img)
      url = $img.attr 'data-src'
      if cache[url]
        cached_image = cache[url]
        $img.attr 'src', "data:image/#{cached_image.format};base64,#{cached_image.data}"
        console.log 'cached image'
      else
        $img.attr('src', url)
        $img.on 'load', =>
          cache[url] =
            format: 'png'
            data: $img.toBase64('png')
          console.log 'no cache'
    @

  toBase64: (format)->
    unless format?
      format = 'png'
    img = @[0]
    canvas = document.createElement("canvas")
    canvas.width = img.width
    canvas.height = img.height
    ctx = canvas.getContext("2d")
    ctx.drawImage(img, 0, 0, img.naturalWidth, img.naturalHeight, 0, 0, img.width, img.height)
    dataURL = canvas.toDataURL("image/#{format}");
    r = new RegExp("^data:image/#{format};base64,")
    dataURL.replace(r, '')
