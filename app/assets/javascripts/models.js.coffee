#
#
#
class App.Models.Note extends Backbone.Model
  initialize: (options)->
    this._updateTitle(options.content)
    this._updateIndex(options.content);
    this.url = "/my_notes/#{options.id}"

  updateContent: (newContent)->
    if newContent != this.get("content")
      this._updateTitle(newContent)
      this._updateIndex(newContent)
      this.set("content", newContent)
      @dirty = true

  saveContent: ->
    this.save()
    @dirty = false

  delete: ->
    console.log 'deleted!'

  isBlank: ->
    !this.get("content")?

  _updateTitle: (content)->
    if content
      @title = content.split("\n")[0]
  _updateIndex: (content)->
    @indexItems = this._markdownToIndexItems(content)

  _markdownToIndexItems: (markdown)->
    if markdown
      lines = markdown.split("\n")
      lines_with_index = $.map(lines, (line, i)->{title:line, line: i + 1})
      indexes = $.grep(lines_with_index, (title_and_index, i)->title_and_index.title.match("^#+"))
      $.map(indexes, (idx)->
        idx.title.match(/^(#+)(.*)$/)
        title = $.trim(RegExp.$2)
        depth = RegExp.$1.length
        new App.Models.NoteIndexItem($.extend(idx, {depth:depth, title:title}))
      )
    else
      []

#
#
#
class App.Models.NoteIndexItem extends Backbone.Model
