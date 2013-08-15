App.Inits =
  initEditor: ->
    $note = $(".note")
    id = $note.attr("data-id")

    isSaveKey = (e)->
      if App.Views.isCtrlPressed(e)
        e.keyCode == 83
      else
        false

    attachGlobalKeyEvents = (note)->
      $('body').on 'keydown', (e)->
        if isSaveKey(e)
          e.preventDefault()
          note.saveContent()

    sidebar = new App.Views.NoteEditorSidebarView(el: $('.sidebar'))
    rightSidebar = new App.Views.RightSidebarView(el: $('.right-sidebar'))

    $.getJSON "#{id}.json", (data)->
      note = new App.Models.Note(data)
      editor = new App.Views.NoteEditorView(el:$(".editor-container"), model:note)
      $(window).bind "beforeunload", (event)->
        if note.dirty
          editor.save()
          "Quit?"
        else
          if note.isBlank()
            note.destroy()
            "Deleted!"
      attachGlobalKeyEvents(note)
      sidebar.on 'resized', => editor.sidebarResized(width: sidebar.width())
      rightSidebar.on 'resized', => editor.rightSidebarResized(width: rightSidebar.width())

      preview = new App.Views.NoteHtmlView(el: $('.preview'), model: note)
      sidebar.load()
      rightSidebar.load()
      #
      noteIndexView = new App.Views.NoteIndexView(el: $('.index'), model: note)
      new App.Views.NoteView(el: $('.note'), model: note, indexView: noteIndexView)

  initNoteList: ->
    notes = new App.Collections.NoteList([])
    notes.url = '/my_notes'
    view = new App.Views.NoteListView(el: $('.notes'), collection: notes)
    preview = new App.Views.NotePreviewView(el: $('.note-preview'))
    view.on 'noteSelected', (id)-> preview.show(id)
    view.fetchMore()
