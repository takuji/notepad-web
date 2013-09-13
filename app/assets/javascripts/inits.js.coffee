App.Inits =
  initEditor: ->
    $note = $(".note")
    editor = new App.Views.NoteView(el: $note)
    id = $note.attr("data-id")
    editor.loadNote id

  initNoteList: ->
    new App.Views.NoteListPage(el: $('.note-list-page'))
