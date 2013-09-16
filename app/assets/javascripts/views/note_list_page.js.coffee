class App.Views.NoteListPage extends Backbone.View
  KEY_CODE_K: 'K'.charCodeAt(0)
  KEY_CODE_J: 'J'.charCodeAt(0)
  KEY_CODE_ENTER: 13

  initialize: (options)->
    console.log options
    @collection_url = options.collection_url
    console.log @collection_url
    $(window).on 'resize', => @resize()
    @search = new App.Views.NoteSearchView(el: $('.note-search'))
    @listenTo @search, 'search:success', @replaceNoteList
    @resize()
    @_initSubviews()
    @_attachGlobalKeyEvents()

  _initSubviews: ->
    notes = new App.Collections.NoteList([])
    notes.url = @collection_url || '/my_notes'
    @note_list_view = new App.Views.NoteListView(el: @$('.note-list-pane'), collection: notes)
    preview = new App.Views.NotePreviewView(el: $('.note-preview'))
    @note_list_view.on 'noteSelected', (id)-> preview.show(id)
    @note_list_view.fetchMore()

  _attachGlobalKeyEvents: ->
    $('body').on 'keydown', (e)=>
      unless @inSearch()
        switch e.keyCode
          when @KEY_CODE_J
            console.log 'J'
            @note_list_view.selectNextItem()
          when @KEY_CODE_K
            console.log 'K'
            @note_list_view.selectPrevItem()
          when @KEY_CODE_ENTER
            @note_list_view.openSelectedNote()
          else
            console.log e.keyCode

  resize: ->
    $window = $(window)
    @$el.height($window.height() - 44)

  replaceNoteList: (notes)->
    delete @note_list_view
    @note_list_view = new App.Views.NoteListView(el: @$('.note-list-pane'), collection: notes)
    @note_list_view.render()

  inSearch: ->
    @search.inSearch()

#
#
#
class App.Views.NoteListView extends Backbone.View
  cache: {}
  selectedNoteView: null
  views: {}
  LIST_ITEM_HEIGHT: 45

  events:
    'mouseenter li': 'preview'
    #'click li':      'openNote'
    'click .more': 'fetchMore'
    'dblclick li': 'openNote'
    'appear .more':  'fetchMore'

  initialize: ->
    @collection.on 'add', @noteAdded, @
    @listenTo @collection, 'remove', @noteRemoved
    @$el.on 'scroll', => @fetchMoreIfReachedBottom()
    @$more = @$('.more')
    @collection.on 'selected', @selectNote, @
    @$noteList = @$('.note-list')
    @$noteList.empty()

  render: ->
    @collection.each (note)=>
      @noteAdded note

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

  openSelectedNote: ->
    if @selectedNoteView
      @selectedNoteView.openNote()

  selectNote: (noteView)->
    if noteView != @selectedNoteView
      @_clearCurrentSelect()
    @selectedNoteView = noteView
    note = noteView.model
    @trigger 'noteSelected', note.id
    console.log "Note #{note.id} selected"

  unselectNote: (noteView)->
    @_clearCurrentSelect()

  selectNextItem: ->
    @_selectNextItem(1)
    if @_isNoteViewHidden @selectedNoteView
      @_scrollToShowNoteListItemView @selectedNoteView

  _isNoteViewHidden: (view)->
    topInParent = @_topInParent(view)
    topInParent + @LIST_ITEM_HEIGHT > @$el.height() || topInParent < 0

  _scrollToShowNoteListItemView: (view)->
    topInParent = @_topInParent(view)
    topInNodeList = @_topInNoteList(view)
    if topInParent > 0
      dy = topInNodeList + @LIST_ITEM_HEIGHT + 10 - @$el.height()
      @$el.scrollTop(dy)
    else
      @$el.scrollTop(topInNodeList)

  _topInParent: (view)->
    view.$el.position().top - @$el.position().top

  _topInNoteList: (view)->
    view.$el.position().top - @$noteList.position().top

  selectPrevItem: ->
    @_selectNextItem(-1)
    if @_isNoteViewHidden @selectedNoteView
      @_scrollToShowNoteListItemView @selectedNoteView

  _selectNextItem: (d)->
    if @selectedNoteView
      current_note = @selectedNoteView.model
      index = @collection.indexOf(current_note)
      next_note = @collection.at(index + d)
      if next_note
        @selectedNoteView.unselect()
        next_note.trigger('select')
    else
      if d > 0
        next_note = @collection.at(0)
        if next_note
          next_note.trigger('select')

  _clearCurrentSelect: ->
    if @selectedNoteView
      @selectedNoteView.unselect()

  noteAdded: (note)->
    console.log "Note #{note.id} added"
    view = new App.Views.NoteListItemView(model: note)
    @listenTo view, 'selected', @selectNote
    @listenTo view, 'unselected', @unselectNote
    view.render()
    @$('.note-list').append view.el
    @views[note.id] = view
    console.log "Note #{note.id} added!"
    @

  noteRemoved: (note)->
    console.log "Note #{note.id} removed"
    view = @views[note.id]
    if view
      @stopListening(view)
      delete @views[note.id]
      console.log "Note #{note.id} removed!"

#
#
#
class App.Views.NoteListItemView extends Backbone.View
  tagName: 'li'
  className: 'note-list-item'
  template: if $('#templates .note-list-item').length then _.template($('#templates .note-list-item').html()) else null

  events:
    'click .delete': 'deleteNote'
    'click .undelete': 'undeleteNote'
    'click': 'toggleSelection'
    'click .edit': 'openNote'

  initialize: ->
    @model.on 'deleted', @remove, @
    @model.on 'undeleted', @remove, @
    @model.on 'select', @select, @
    @render()

  render: ->
    id = @model.get('id')
    @$el.attr('data-id': id)
    params =
      title: @model.get('title')
      updated_at: @_iso8601ToDateString(@model.get('updated_at'))
    @$el.html @template(params)
    @

  _iso8601ToDateString: (dateISO8601)->
    @_timeToDateString @_iso8601ToTime(dateISO8601)

  _iso8601ToTime: (dateISO8601)->
    new Date(Date.parse dateISO8601)

  _timeToDateString: (time)->
    "#{time.getFullYear()}/#{time.getMonth() + 1}/#{time.getDate()}"

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
    console.log "Deleting note #{@model.get('id')}"
    e.stopPropagation()
    @model.delete()

  undeleteNote: (e)->
    console.log 'delete'
    e.stopPropagation()
    @model.undelete()

  remove: ->
    console.log "1"
    if @model.collection
      console.log "2"
      @model.collection.remove @model
    console.log "3"
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
  in_search: false

  events:
    'click .btn': 'search'
    'focus #q': 'startSearch'
    'blur #q': 'stopSearch'

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

  startSearch: ->
    console.log 'start search'
    @in_search = true

  stopSearch: ->
    console.log 'stop search'
    @in_search = false

  inSearch: ->
    @in_search