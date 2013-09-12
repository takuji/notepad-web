#
#
#
class App.Models.Note extends Backbone.Model
  initialize: (options)->
    @.on 'change:content', @updateIndex, @
    @.on 'change:content', @updateTitle, @
    @._updateTitle(options.content)
    @._updateIndex(options.content);
    @.url = "/my_notes/#{options.id}"

  updateContent: (newContent)->
    if newContent != this.get("content")
      @dirty = true
      @._updateTitle(newContent)
      @._updateIndex(newContent)
      @.set("content", newContent)

  saveContent: ->
    this.save()
    @dirty = false
    @trigger 'saved'

  isModified: ->
    !!@dirty

  updateIndex: ->
    @_updateIndex @get('content')
    @trigger 'index_updated', @

  updateTitle: ->
    @_updateTitle @get('title')

  delete: ->
    console.log 'deleted!'
    q = $.post @url + '/delete'
    q.done =>
      console.log 'success'
      @trigger 'deleted', @
    q.fail =>
      console.log 'failed'

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
