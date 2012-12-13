Note = Backbone.Model.extend(
  initialize: (options)->
    this._updateIndex();

  updateContent: (newContent)->
    this._updateIndex(newContent)
    this.set("content", newContent)

  _updateIndex: (content)->
    @indexItems = this._markdownToIndexItems(content)

  _markdownToIndexItems: (markdown)->
    if markdown
      lines = markdown.split("\n")
      lines_with_index = $.map(lines, (line, i)->{title:line, line: i + 1})
      indexes = $.grep(lines_with_index, (title_and_index, i)->title_and_index.title.match("^#+"))
      $.map(indexes, (idx)->
        idx.title.match(/^(#+)(.+)$/)
        title = $.trim(RegExp.$2)
        depth = RegExp.$1.length
        new NoteIndexItem($.extend(idx, {depth:depth, title:title}))
      )
    else
      []
)

NoteEditorView = Backbone.View.extend(
  events:
    "keyup": "update"

  initialize: (options)->
    _.bindAll(this, "render")
    this.model.bind("change", this.render)
    this.render()
    this.$textArea = $("textarea", this.el).autosize();

  render: ->
    indexItems = this.model.indexItems
    self = this
    views = $.map(indexItems, (item)->new NoteIndexItemView(model:item, editor:self))
    list = $("<ul>")
    _.each(views, (view)->list.append(view.toElem()))
    $(".index").html(list);

  update: (e)->
    this.model.updateContent($("textarea", this.el).val())

  lineCount: -> this.$textArea.val().split("\n").length;

  scrollTo: (lineNo)->
    y0 = this.$textArea.offset().top
    h  = this.$textArea.height()
    y  = h * (lineNo - 1) / this.lineCount()
    window.scrollTo(0, Math.floor(y));
)

NoteIndexView = Backbone.View.extend(
  initialize: (options)->
    _.bindAll(this)
    this.model.bind("change:content", this.render)
    this.render()
  render: ->
    _.map(this.model.indexItems, (item)-> new NoteIndexItemView(model:item))
)

NoteIndexItem = Backbone.Model.extend(

)

NoteIndexItemView = Backbone.View.extend(
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
    this.$el.text(this.model.get("title")).attr("data-line":this.model.get("line"), "data-depth":this.model.get("depth"))

  scroll: ->
    lineNo = this.model.get("line")
    this.editor.scrollTo(lineNo)
)


$ ->
  $("body:has(.note)").css("backgroundColor": "#e4e4e4")
  if $(".editor").length
    id = $(".note").attr("data-id")
    $.getJSON("#{id}.json", (data)->
      note = new Note(data)
      editor = new NoteEditorView(el:$(".editor"), model:note)
    )