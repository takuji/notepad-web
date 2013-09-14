class App.Views.NoteListPage extends Backbone.View
  initialize: (options)->
    console.log options
    @collection_url = options.collection_url
    console.log @collection_url
    $(window).on 'resize', => @resize()
    @search = new App.Views.NoteSearchView(el: $('.note-search'))
    @listenTo @search, 'search:success', @replaceNoteList
    @resize()
    @_initSubviews()

  _initSubviews: ->
    notes = new App.Collections.NoteList([])
    notes.url = @collection_url || '/my_notes'
    @note_list_view = new App.Views.NoteListView(el: @$('.note-list-pane'), collection: notes)
    preview = new App.Views.NotePreviewView(el: $('.note-preview'))
    @note_list_view.on 'noteSelected', (id)-> preview.show(id)
    @note_list_view.fetchMore()

  resize: ->
    $window = $(window)
    @$el.height($window.height() - 44)

  replaceNoteList: (notes)->
    delete @note_list_view
    @note_list_view = new App.Views.NoteListView(el: @$('.note-list-pane'), collection: notes)
    @note_list_view.render()

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
    @$noteList.empty()

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
    'click .undelete': 'undeleteNote'
    'click': 'toggleSelection'
    'click .edit': 'openNote'

  initialize: ->
    @model.on 'deleted', @remove, @
    @model.on 'undeleted', @remove, @
    @render()

  render: ->
    id = @model.get('id')
    @$el.attr 'data-id', id
    title = @model.get('title')
    template = _.template $('#templates .note-index-actions-template').html()
    actions = template link: "/my_notes/#{id}"
    @$el.html(title)
    time = new Date(Date.parse @model.get('created_at'))
    time_string = "#{time.getFullYear()}/#{time.getMonth() + 1}/#{time.getDate()}"
    $('<div>').addClass('created_at').text(time_string).append(actions).appendTo(@$el)
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

  openNote: (e)->
    location.href = "/my_notes/#{@model.get('id')}/edit"

  deleteNote: (e)->
    console.log 'delete'
    e.stopPropagation()
    @model.delete()

  undeleteNote: (e)->
    console.log 'delete'
    e.stopPropagation()
    @model.undelete()

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


class App.Views.NoteSearchView extends Backbone.View
  el: $('.note-search')

  events:
    'click .btn': 'search'

  search: (e)->
    e.preventDefault()
    q = @$('#q').val()
    if !!q
      @_searchNotes q
    else
      @_loadNotes()

  _searchNotes: (q)->
    @collection = new App.Collections.NoteList([])
    encoded_q = encodeURIComponent(q)
    @collection.url = "/my_notes/search?q=#{encoded_q}"
    @_fetchNotes(@collection)

  _loadNotes: ->
    @collection = new App.Collections.NoteList([])
    @collection.url = '/my_notes'
    @_fetchNotes(@collection)

  _fetchNotes: (collection)->
    collection.fetch
      success: =>
        console.log collection.size()
        @trigger 'search:success', collection
