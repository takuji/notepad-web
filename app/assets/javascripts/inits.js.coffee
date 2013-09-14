App.Inits =
  initEditor: ->
    $note = $(".note")
    editor = new App.Views.NoteView(el: $note)
    id = $note.attr("data-id")
    editor.loadNote id

  initNoteList: ->
    new App.Views.NoteListPage(el: $('.note-list-page'))

  initDeletedNoteList: ->
    new App.Views.NoteListPage(el: $('.note-list-page'), collection_url: '/my_notes/deleted')
