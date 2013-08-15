#
#
#
class App.Views.NoteEditorView extends Backbone.View
  events:
    'click': 'startEditing'
    'keydown': 'onKeyDown'
    'keyup': 'onKeyUp'

  debug: false

  initialize: (options)->
    @$textArea = @$('textarea').autosize().focus()
    self = this
    _.bindAll(this, "render")
    this.model.on "change", this.render
    if this.model.get("content")
      this.$textArea.val(this.model.get("content"))
      setTimeout((-> self.$textArea.trigger("autosize")), 0) # タイマーで実行しないとautosizeが機能しなかったので已む無くそうしている。
    #this.$textArea.trigger("autosize")
    this.render()
    this.timer = setInterval((-> self.checkChange()), 1000)
    this.autoSaveInterval = 5 * 1000
    $("#debug").toggle(this.debug)
    @$textArea.textareaCaret(cursorMoved: (params)=> @onCursorMoved(params))

  render: ->
    indexItems = this.model.indexItems
    self = this
    views = $.map(indexItems, (item)-> new App.Views.NoteIndexItemView(model:item, editor:self))
    list = $("<ul>")
    _.each(views, (view)->list.append(view.render().el))
    $(".index").html(list);
    if this.debug
      if @lastKeyup
        $("#debug > .last-keyup").html(@lastKeyup.toString())

  update: (e)->
    @lastKeyup = new Date()
    this.model.updateContent($("textarea", this.el).val())

  lineCount: -> this.$textArea.val().split("\n").length;

  scrollTo: (lineNo)->
    y0 = this.$textArea.offset().top
    h  = this.$textArea.height()
    y  = h * (lineNo - 1) / this.lineCount()
    window.scrollTo(0, Math.floor(y));

  checkChange: ->
    if @lastKeyup
      d = new Date() - @lastKeyup
      if d > @autoSaveInterval && this.model.dirty
        this.model.saveContent()
      $("#debug > .time-since-last-change").text(Math.floor(d / 1000))

  startEditing: ->
    this.$textArea.focus()

  save: ->
    this.update()
    this.model.saveContent()

  sidebarResized: (size)->
    if size.width?
      @$el.css 'left', size.width + "px"

  rightSidebarResized: (size)->
    if size.width?
      @$el.css 'right', size.width + 'px'

  onKeyDown: (e)->
    switch e.keyCode
      when 9 # tab
        e.preventDefault()
        console.log @$textArea.getCaretPos()
        if @caretPos
          @forwardHeadingLevel(@caretPos.l_line)
      else
        @update(e)

  onKeyUp: (e)->
    console.log @$textArea.getCaretPos()

  forwardHeadingLevel: (l_line)->
    console.log "l_line = #{l_line}"
    line = @getLine(l_line)
    console.log line
    level = @headingLevel(line)
    console.log "heading level = #{level}"
    nextLevel = (level + 1) % 7
    h = @makeHeading(nextLevel)
    heading = @extractHeading(line)
    newLine = h + heading
    text = @$textArea.val()
    @$textArea.val @replaceLine(text, l_line, newLine)
    newCaretPos = if nextLevel > level then @caretPos.pos + 1 else @caretPos.pos - 6
    @$textArea.setCaretPosition(newCaretPos)

  moveCaretToLine: (line_no)->
    pos = @rangeOfLine(line_no, @$textArea.val())
    @$textArea.setCaretPosition(pos.start)

  getLine: (l_line)->
    @$textArea.val().split("\n")[l_line - 1]

  headingLevel: (line) ->
    level = 0
    while line[level] == '#'
      level += 1
    if level <= 6 then level else 0

  makeHeading: (level)->
    h = ''
    _.times(level, -> h += '#')
    h

  extractHeading: (line)->
    line.replace /^#+/, ''

  onCursorMoved: (params)->
    console.log params
    @caretPos = params

  insertAt: (pos, s)->
    text = @$textArea.val()
    t1 = text.substring 0, pos
    t2 = text.substring pos
    @$textArea.val t1 + s + t2

  replaceLine: (text, line_no, newLineText)->
    range = @rangeOfLine(line_no, text)
    t1 = text.substring(0, range.start)
    t2 = if range.end >= 0 then text.substring(range.end) else ''
    t1 + newLineText + t2

  rangeOfLine: (line_no, text)->
    pos = 0
    _.times line_no - 1, ->
      newLinePos = text.indexOf("\n", pos)
      pos = newLinePos + 1
    newLinePos = text.indexOf("\n", pos)
    {start: pos, end: newLinePos}

#
#
#
class App.Views.NoteHtmlView extends Backbone.View
  html: null

  initialize: ->
    _.bindAll @
    @model.on 'change', @redraw
    $(window).on 'resize', @resize
    @redraw()
    @resize()

  render: ->
    @$el.html @html
    @

  compile: ->
    @html = marked @model.get('content')
    @model.set 'html_content', @html

  _compile: ->
    if marked?
      marked @model.get('content')
    else if markdown?
      markdown.toHTML @model.get('content')
    else
      ''

  redraw: ->
    @compile()
    @render()

  resize: ->
    #@$el.height(($(window).height() - 54) + "px")

#
#
#
class App.Views.RightSidebarView extends Backbone.View
  visible: false

  initialize: ->
    @$handle = @$('.handle')
    @$handle.draggable
      axis: 'x'
      stop: (e, ui)=> @resize(e)
#      drag: (e, ui)=> @resize(e)

  resize: (e)->
    console.log @$handle.offset()
    w = @$el.offset().left + @width() - @$handle.offset().left
    console.log w
    console.log @$el.width()
    @$el.width w
    @$handle.css 'left', 0
    @save()
    @trigger 'resized'

  width: ->
    @$el.width()

  save: ->
    $.cookie 'right-sidebar-width', @width()
    $.cookie 'right-sidebar-visible', @visible

  load: ->
    w = $.cookie('right-sidebar-width')
    if w
      @$el.width +w
      @trigger 'resized'

#
#
#
class App.Views.NoteEditorSidebarView extends Backbone.View
  visible: false
  #events:
    #'drag .handle': 'resize'
    #'stop .handle': 'resize'

  initialize: ->
    @$handle = @$('.handle')
    @$handle.draggable
      axis: 'x'
      appendTo: 'body'
      stop: (e, ui)=> @resize(e)
      #drag: (e, ui)=> @resize(e)

  resize: (e)->
    console.log e
    @$el.width @$handle.position().left
    @save()
    @trigger 'resized'

  width: ->
    @$el.width() + 10

  save: ->
    $.cookie 'sidebar-width', @$el.width()
    $.cookie 'sidebar-visible', @visible

  load: ->
    w = $.cookie('sidebar-width')
    if w
      @$el.width +w
      @trigger 'resized'
#
#
#
class App.Views.NoteIndexView extends Backbone.View
  initialize: (options)->
    _.bindAll(this)
    @model.on 'change:content', @render
    @render()
#    @$('.handle').draggable axis: 'x'

  render: ->
    _.map(@model.indexItems, (item)-> new App.Views.NoteIndexItemView(model:item))

#
#
#
class App.Views.NoteIndexItemView extends Backbone.View
  tagName: "li"
  className: "indexItem"
  mark: '<i class="icon-caret-right"></i>'
  events:
    "click": "scroll"

  initialize: (options)->
    @editor = options.editor

  render: ->
    content = this.model.get("title") || "?"
    @$el.html(@mark + ' ' + content).attr("data-line":this.model.get("line"), "data-depth":this.model.get("depth"))
    @

  toElem: ->
    this.$el.text(this.model.get("title") || "?").attr("data-line":this.model.get("line"), "data-depth":this.model.get("depth"))

  scroll: ->
    lineNo = this.model.get("line")
    this.editor.scrollTo(lineNo)

#
#
#
class App.Views.NoteListView extends Backbone.View
  cache: {}

  events:
    'mouseenter li': 'preview'
    'click li':      'openNote'
    'click .more':   'fetchMore'
    'appear .more':  'fetchMore'

  initialize: ->
    _.bindAll @
    @collection.on 'add', @addItem
    $(window).on 'scroll', @fetchMoreIfReachedBottom
    @$more = @$('.more')

  render: ->
    @collection.each (note)=>
      @addItem note

  fetchMore: ->
    console.log 'appear'
    @collection.more()

  fetchMoreIfReachedBottom: ->
    if @shouldFetch()
      @fetchMore()

  shouldFetch: ->
    @$more.viewportOffset().top < $(window).height() && @collection.hasNext()

  preview: (e)->
    $note = $(e.currentTarget)
    id = $note.attr("data-id")
    @trigger 'noteSelected', id

  openNote: (e)->
    $note = $(e.currentTarget)
    id = $note.attr("data-id")
    location.href = "/my_notes/#{id}"

  addItem: (note)->
    view = new App.Views.NoteListItemView(model: note)
    @$('ul.note-list').append view.render().el

#
#
#
class App.Views.NoteListItemView extends Backbone.View
  tagName: 'li'
  className: 'note-list-item'

  events:
    'click .delete': 'delete'

  render: ->
    id = @model.get('id')
    @$el.attr 'data-id', id
    link = $('<a>').attr('href', "/my_notes/#{id}").text(@model.get('title'))
    template = _.template $('#templates .note-index-actions-template').html()
    actions = template link: "/my_notes/#{id}"
    @$el.html(link).append(actions)
    @

  delete: (e)->
    console.log 'delete'
    e.stopPropagation()

#
#
#
class App.Views.NotePreviewView extends Backbone.View
  cache: {}
  note_id: null

  show: (note_id)->
    @note_id = note_id
    @render()

  render: ->
    if @note_id
      if @cache[@note_id]
        @$el.html(@cache[@note_id])
      else
        @$el.load "/my_notes/#{@note_id}/html_content", (responseText)=>
          @cache[@note_id] = responseText
    @