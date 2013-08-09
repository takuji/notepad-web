#
#
#
App.Views.NoteEditorView = Backbone.View.extend
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
App.Views.NoteIndexView = Backbone.View.extend
  initialize: (options)->
    _.bindAll(this)
    this.model.bind("change:content", this.render)
    this.render()
  render: ->
    _.map(this.model.indexItems, (item)-> new App.Views.NoteIndexItemView(model:item))

#
#
#
App.Views.NoteIndexItemView = Backbone.View.extend
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
