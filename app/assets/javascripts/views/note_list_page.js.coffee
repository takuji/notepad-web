class App.Views.NoteListPage extends Backbone.View
  initialize: ->
    $(window).on 'resize', @resize, @
    @resize()

  resize: ->
    $window = $(window)
    @$el.height($window.height() - 44)

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
    view.render()
    @$el.append view.el

#
#
#
class App.Views.NoteListItemView extends Backbone.View
  tagName: 'li'
  className: 'note-list-item'

  events:
    'click .delete': 'deleteNote'

  initialize: ->
    @model.on 'deleted', @remove, @
    @render()

  render: ->
    id = @model.get('id')
    @$el.attr 'data-id', id
    link = $('<a>').attr('href', "/my_notes/#{id}").text(@model.get('title'))
    template = _.template $('#templates .note-index-actions-template').html()
    actions = template link: "/my_notes/#{id}"
    @$el.html(link).append(actions)
    @

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
