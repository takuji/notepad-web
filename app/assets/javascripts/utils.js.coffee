$.fn.extend
  viewportOffset: ->
    $window = $(window)
    p = @offset()
    {left: p.left - $window.scrollLeft(), top: p.top - $window.scrollTop()}
