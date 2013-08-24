App.Inits =
  initEditor: ->
    $note = $(".note")
    editor = new App.Views.NoteView(el: $note)
    id = $note.attr("data-id")
    editor.loadNote id

  initNoteList: ->
    new App.Views.NoteListPage(el: $('.note-list-page'))
    notes = new App.Collections.NoteList([])
    notes.url = '/my_notes'
    view = new App.Views.NoteListView(el: $('.note-list-pane'), collection: notes)
    preview = new App.Views.NotePreviewView(el: $('.note-preview'))
    view.on 'noteSelected', (id)-> preview.show(id)
    view.fetchMore()
