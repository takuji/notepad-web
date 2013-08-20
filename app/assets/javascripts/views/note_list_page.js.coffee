class App.Views.NoteListPage extends Backbone.View
  initialize: ->
    $(window).on 'resize', => @resize()
    @resize()

  resize: ->
    $window = $(window)
    @$el.height($window.height() - 44)

#
#
#
class App.Views.NoteListView extends Backbone.View
  cache: {}
  selectedNoteView: null

  events:
    'mouseenter li': 'preview'
    #'click li':      'openNote'
    'click .more': 'fetchMore'
    'dblclick li': 'openNote'
    'appear .more':  'fetchMore'

  initialize: ->
    _.bindAll @
    @collection.on 'add', @addItem
    $(window).on 'scroll', @fetchMoreIfReachedBottom
    @$more = @$('.more')
    @collection.on 'selected', @selectNote
    @$noteList = @$('.note-list')

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
    unless @isNoteSelected()
      $note = $(e.currentTarget)
      id = $note.attr("data-id")
      @trigger 'noteSelected', id

  isNoteSelected: ->
    @selectedNoteView? && @selectedNoteView.isSelected()

  openNote: (e)->
    $note = $(e.currentTarget)
    id = $note.attr("data-id")
    location.href = "/my_notes/#{id}/edit"

  selectNote: (noteView)->
    if noteView != @selectedNoteView
      @_clearCurrentSelect()
    @selectedNoteView = noteView
    note = noteView.model
    @trigger 'noteSelected', note.id
    console.log "Note #{note.id} selected"

  unselectNote: (noteView)->
    @_clearCurrentSelect()

  _clearCurrentSelect: ->
    if @selectedNoteView
      @selectedNoteView.unselect()

  addItem: (note)->
    view = new App.Views.NoteListItemView(model: note)
    @listenTo view, 'selected', @selectNote
    @listenTo view, 'unselected', @unselectNote
    view.render()
    @$('.note-list').append view.el

#
#
#
class App.Views.NoteListItemView extends Backbone.View
  tagName: 'li'
  className: 'note-list-item'

  events:
    'click .delete': 'deleteNote'
    'click': 'toggleSelection'

  initialize: ->
    @model.on 'deleted', @remove, @
    @render()

  render: ->
    id = @model.get('id')
    @$el.attr 'data-id', id
    title = @model.get('title')
    template = _.template $('#templates .note-index-actions-template').html()
    actions = template link: "/my_notes/#{id}"
    @$el.html(title).append(actions)
    @

  isSelected: ->
    @$el.hasClass 'selected'

  toggleSelection: ->
    if @isSelected()
      @unselect()
    else
      @select()

  select: ->
    @$el.addClass 'selected'
    @trigger 'selected', @

  unselect: ->
    @$el.removeClass 'selected'

  deleteNote: (e)->
    console.log 'delete'
    e.stopPropagation()
    @model.delete()

  remove: ->
    if @model.collection
      @model.collection.remove @model
    @$el.remove()

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
      @hightlightSyntax()
    @

  hightlightSyntax: ->
    @$('pre code').each (i, elm)->
      hljs.highlightBlock(elm)
