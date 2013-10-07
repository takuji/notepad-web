class App.Views.Dashboard extends Backbone.View
  KEY_CODE_K: 'K'.charCodeAt(0)
  KEY_CODE_J: 'J'.charCodeAt(0)
  KEY_CODE_ENTER: 13
  KEY_CODE_DELETE: 46

  marginTop: 50

  current_note: null

  initialize: (options)->
    @_initSubviews()
    @_attachGlobalKeyEvents()

  _initSubviews: ->

  _attachGlobalKeyEvents: ->
    $('body').on 'keydown', (e)=>
      switch e.keyCode
        when @KEY_CODE_J
          console.log 'J'
          @selectNextNote()
        when @KEY_CODE_K
          console.log 'K'
          @selectPrevNote()
        when @KEY_CODE_ENTER
          @openSelectedNote()
        when @KEY_CODE_DELETE
          @deleteSelectedNote()
        else
          console.log e.keyCode

  selectNextNote: ->
    console.log 'Next'
    if @current_note
      $notes = $(@current_note).next()
      if $notes.length > 0
        @_selectNote($notes[0])
    else
      $notes = @$('.note')
      if $notes.length > 0
        @_selectNote($notes[0])

  _selectNote: (note)->
    @current_note = note
    @_scrollToNote(note)

  _scrollToNote: (note)->
    $note = $(note)
    y = $note.offset().top
    console.log y
    $(window).scrollTop(y - @marginTop)

  selectPrevNote: ->
    console.log 'Prev'
    if @current_note
      $notes = $(@current_note).prev()
      if $notes.length > 0
        @_selectNote($notes[0])
  
  openSelectedNote: ->
    if @current_note
      id = $(@current_note).attr('data-id')
      location.href = "/my_notes/#{id}"

  deleteSelectedNote: ->
    unless @inTrash()
      @note_list_view.deleteSelectedNote()

  inTrash: ->
    !!@collection_url
