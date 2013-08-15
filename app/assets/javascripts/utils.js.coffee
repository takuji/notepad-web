$.fn.extend
  viewportOffset: ->
    $window = $(window)
    p = @offset()
    {left: p.left - $window.scrollLeft(), top: p.top - $window.scrollTop()}

  getCaretPos: ->
    el = @[0]
    if el.selectionStart
      el.selectionStart
    else if document.selection
      el.focus()
      r = document.selection.createRange()
      if r == null
        0
      else
        re = el.createTextRange()
        rc = re.duplicate()
        re.moveToBookmark(r.getBookmark())
        rc.setEndPoint('EndToStart', re)
        rc.text.length
    else
      0

  textareaCaret: ->
    options = if arguments.length > 0 then arguments[0] else {}
    @textareaHelper()
    if options['cursorMoved']
      cursorMoved = options['cursorMoved']
      if typeof(cursorMoved) == 'function'
        @.on 'keyup', =>
          pos = @getCaretPos()
          prevPos = @data('prevPos')
          if !prevPos? || (prevPos.pos != pos)
            content = @.val()
            caretPos = @textareaHelper('caretPos')
            val =
              pos: pos
              caretPos: caretPos
              l_line: content.substr(0, pos).split("\n").length
              p_line: (caretPos.top - 10) / 20 + 1
            cursorMoved val
            @data 'prevPos', val
