Backbone.View.prototype.isVisible = ->
  @$el.css('display') != 'none'

#
#
#
class App.Views.NoteView extends Backbone.View
  marginTop: 44

  initialize: ->
    _.bindAll(@)
    @$window = $(window)
    @$window.on 'resize', @render

    @_setupViews()
    @render()

  _setupViews: ->
    @sidebar = new App.Views.NoteEditorSidebarView(el: @$('.sidebar'))
    @rightSidebar = new App.Views.RightSidebarView(el: @$('.right-sidebar'))
    # editor pane
    @editor = new App.Views.NoteEditorView(el: @$(".editor-container"))
    @editor.listenTo @sidebar, 'resized', => @editor.sidebarResized(width: @sidebar.width())
    @editor.listenTo @rightSidebar, 'resized', => @editor.rightSidebarResized(width: @rightSidebar.width())
    @sidebar.trigger 'resized'
    @rightSidebar.trigger 'resized'
    @toggleSidebar($.cookie('show-sidebar') != 'false')
    @toggleRightSidebar($.cookie('show-preview') != 'false')
    # menu
    @menu = new App.Views.NoteMenuView()
    @menu.on 'change:sidebar', @toggleSidebar
    @menu.on 'change:preview', @toggleRightSidebar

  loadNote: (id)->
    @model = new App.Models.Note(id: id)
    @model.url = "/my_notes/#{id}.json"
    @model.fetch
      success: =>
        @editor.setNote @model
        @preview = new App.Views.NoteHtmlView(el: @$('.preview'), model: @model)
        @noteIndexView = new App.Views.NoteIndexView(el: @$('.index'), model: @model)
        @listenTo @noteIndexView, 'heading:selected', @onHeadingSelected
        @_attachGlobalKeyEvents(@model)
      error: =>
        console.log "Error!"

  onHeadingSelected: (heading)->
    lineNo = heading.get('line')
    @editor.scrollTo(lineNo)

  _attachGlobalKeyEvents: (note)->
    $('body').on 'keydown', (e)=>
      if @_isSaveKey(e)
        e.preventDefault()
        note.saveContent()

  _isSaveKey: (e)->
    if App.Views.isCtrlPressed(e)
      e.keyCode == 83
    else
      false

  render: ->
    height = @$window.height() - @marginTop
    @$el.height(height)
    console.log height
    @

  toggleSidebar: (flag)->
    @sidebar.setVisible(flag)
    if @sidebar.isVisible()
      @editor.setLeft(@sidebar.width())
    else
      @editor.setLeft(0)

  toggleRightSidebar: (flag)->
    @rightSidebar.setVisible(flag)
    if @rightSidebar.isVisible()
      @editor.rightSidebarResized(width: @rightSidebar.width())
    else
      @editor.rightSidebarResized(width: 0)

#
#
#
class App.Views.NoteEditorView extends Backbone.View
  events:
    'click': 'startEditing'
    'keydown': 'onKeyDown'
    'keyup': 'onKeyUp'
    'focus textarea': 'updateCaretPos'

  debug: false

  initialize: (options)->
    @$textArea = @$('textarea').autosize().focus()
    @render()
    if @model
      @setNote @model

    @_initImageUploader()

  _initImageUploader: ->
    @$('.image-uploader').fileupload
      dataType: 'json'
      done: (e, data)=>
        _.each data.result.files, (file, i)=>
          console.log i
          @_insertAtCaretPos("![photo](#{file.url})")
          @_updateModel()
          @trigger 'image:uploaded', file
      dropZone: @$textArea

  setNote: (note)->
    @model = note
    @model.on "change", @render, @
    if @model.get("content")
      @$textArea.val(@model.get("content"))
      setTimeout((=> @$textArea.trigger("autosize")), 0) # タイマーで実行しないとautosizeが機能しなかったので已む無くそうしている。
    @timer = setInterval((=> @checkChange()), 1000)
    @autoSaveInterval = 5 * 1000
    $("#debug").toggle(this.debug)
    @$textArea.textareaCaret(cursorMoved: (params)=> @onCursorMoved(params))
    $(window).bind "beforeunload", (event)=>
      if @model.dirty
        @save()

  render: ->

  setLeft: (left)->
    @$el.css('left', left + 'px')

  update: (e)->
    @lastKeyup = new Date()
    @_updateModel()

  _updateModel: ->
    @model.updateContent(@$textArea.val())

  lineCount: -> this.$textArea.val().split("\n").length;

  scrollTo: (lineNo)->
    y0 = this.$textArea.offset().top
    h  = this.$textArea.height()
    y  = h * (lineNo - 1) / this.lineCount()
    @$('.editor').scrollTop(Math.floor(y))

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
        if @caretPos
          @forwardHeadingLevel(@caretPos.l_line)

  _isLineHeading: ->
    line = @getLine(@caretPos.l_line)
    line[0] == '#'

  _insertTabAtCaretPos: ->
    @_insertAtCaretPos("\t")

  _insertAtCaretPos: (text)->
    content = @getContent()
    pos = @caretPos.pos
    @$textArea.val content.substring(0, pos) + text + content.substring(pos)
    @$textArea.setCaretPosition(pos + text.length)

  getContent: ->
    @$textArea.val()

  onKeyUp: (e)->
    console.log @$textArea.getCaretPos()
    @update(e)

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

  updateCaretPos: ->
    @caretPos = @$textArea.getCaretLocation()

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
    html = @_escapeImageSrc(@html)
    $content = $(html)
    $content.find('img').imagecache()
    @$el.html $content
    @hightlightSyntax()
    @

  _escapeImageSrc: (html)->
    html.replace /\ssrc=/g, ' data-src='

  compile: ->
    @html = marked (@model.get('content') || '')
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

  hightlightSyntax: ->
    @$('pre code').each (i, elm)->
      hljs.highlightBlock(elm)

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
    @load()

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

  setVisible: (flag)->
    @$el.toggle(flag)

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
    @load()
  #drag: (e, ui)=> @resize(e)

  resize: (e)->
    console.log e
    if @$handle.position().left > 30
      @$el.width @$handle.position().left
      @save()
      @trigger 'resized'
    else
      @$handle.css 'left', @$el.width()

  width: ->
    @$el.width() + @$handle.width()

  save: ->
    $.cookie 'sidebar-width', @$el.width()
    $.cookie 'sidebar-visible', @visible

  load: ->
    w = $.cookie('sidebar-width')
    if w
      @$el.width(+w)
      @trigger 'resized'

  setVisible: (flag)->
    @$el.toggle(flag)

  isVisible: ->
    @$el.css('display') != 'none'

#
#
#
class App.Views.NoteIndexView extends Backbone.View
  initialize: ->
    _.bindAll(@)
    @model.on 'index_updated', @render
    @render()

  render: ->
    console.log "NoteIndexView.render"
    indexItems = @model.indexItems
    views = _.map(indexItems, (item)=> new App.Views.NoteIndexItemView(model: item))
    @stopListening()
    _.each views, (view)=> @listenTo(view, 'clicked', @headingClicked)
    list = $("<ul>")
    _.each(views, (view)-> list.append(view.render().el))
    @$el.html(list);
    if this.debug
      if @lastKeyup
        $("#debug > .last-keyup").html(@lastKeyup.toString())

  headingClicked: (heading)->
    @trigger 'heading:selected', heading
#
#
#
class App.Views.NoteIndexItemView extends Backbone.View
  tagName: "li"
  className: "indexItem"
  mark: '<i class="icon-caret-right"></i>'
  events:
    "click": "onClicked"

  initialize: (options)->
    @editor = options.editor

  render: ->
    content = @model.get("title") || "?"
    @$el.html(@mark + ' ' + content).attr("data-line": @model.get("line"), "data-depth": @model.get("depth"))
    @

  toElem: ->
    this.$el.text(@model.get("title") || "?").attr("data-line": @model.get("line"), "data-depth": @model.get("depth"))

  onClicked: ->
    @trigger 'clicked', @model

class App.Views.NoteMenuView extends Backbone.View
  el: $('.note-editor-menu')
  show_sidebar: true
  show_preview: true
  show_image_panel: false

  events:
    'click .toggle-sidebar': 'toggleSidebar'
    'click .toggle-preview': 'togglePreview'
    'click .toggle-image-panel': 'toggleImagePanel'

  initialize: ->
    @load()
    @render()

  toggleSidebar: ->
    @show_sidebar = !@show_sidebar
    @save()
    @trigger 'change:sidebar'
    @render()

  togglePreview: ->
    @show_preview = !@show_preview
    @save()
    @trigger 'change:preview'
    @render()

  toggleImagePanel: ->
    @show_image_panel = !@show_image_panel
    if @show_image_panel
      panel = new App.Views.ImagePanel()
      panel.show()

  save: ->
    $.cookie 'show-sidebar', @show_sidebar
    $.cookie 'show-preview', @show_preview

  load: ->
    @show_sidebar = $.cookie('show-sidebar') != 'false'
    @show_preview = $.cookie('show-preview') != 'false'

  render: ->
    @$('.toggle-sidebar i').toggle(@show_sidebar)
    @$('.toggle-preview i').toggle(@show_preview)
    console.log @show_sidebar

class App.Views.ImagePanel extends Backbone.View
  el: $('#image-panel')

  initialize: ->

  render: ->
    @

  show: ->
    @$el.show()
    @_upload()

  _upload: ->
    @$('#image_file').fileupload
      dataType: 'json'
      done: (e, data)=>
        _.each data.result.files, (file, i)=>
          console.log i
          @trigger 'image:uploaded', file
