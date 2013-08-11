#
#
#
class App.Views.NoteEditorView extends Backbone.View
  events:
    "keyup": "update"
    "click": "startEditing"

  debug: false

  initialize: (options)->
    this.$textArea = $("textarea", this.el).autosize()
    self = this
    _.bindAll(this, "render")
    this.model.bind("change", this.render)
    if this.model.get("content")
      this.$textArea.val(this.model.get("content"))
      setTimeout((-> self.$textArea.trigger("autosize")), 0) # タイマーで実行しないとautosizeが機能しなかったので已む無くそうしている。
    #this.$textArea.trigger("autosize")
    this.render()
    this.timer = setInterval((-> self.checkChange()), 1000)
    this.autoSaveInterval = 5 * 1000
    $("#debug").toggle(this.debug)

  render: ->
    indexItems = this.model.indexItems
    self = this
    views = $.map(indexItems, (item)-> new App.Views.NoteIndexItemView(model:item, editor:self))
    list = $("<ul>")
    _.each(views, (view)->list.append(view.toElem()))
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

#
#
#
class App.Views.NoteIndexView extends Backbone.View
  initialize: (options)->
    _.bindAll(this)
    this.model.bind("change:content", this.render)
    this.render()
  render: ->
    _.map(this.model.indexItems, (item)-> new App.Views.NoteIndexItemView(model:item))

#
#
#
class App.Views.NoteIndexItemView extends Backbone.View
  tagName: "li"
  className: "indexItem"
  events:
    "click": "scroll"

  initialize: (options)->
    @editor = options.editor

  render: ->
    template = _.template($("#index-template").html())
    this.$el.html(template(this.model.toJSON()))
    this

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

  initialize: ->
    _.bindAll @
    @collection.on 'add', @addItem

  render: ->
    @collection.each (note)=>
      @addItem note

  fetchMore: ->
    @collection.more()

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
    @$('ul').append view.render().el

#
#
#
class App.Views.NoteListItemView extends Backbone.View
  tagName: 'li'

  render: ->
    id = @model.get('id')
    @$el.attr 'data-id', id
    link = $('<a>').attr('href', "/my_notes/#{id}").text(@model.get('title'))
    @$el.html link
    @

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
        @$el.load "/my_notes/#{@note_id}/content", (responseText)=>
          @cache[@note_id] = responseText
    @