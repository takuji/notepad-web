$("body:has(.note)").css("backgroundColor": "#e4e4e4")

App.Inits =
  initEditor: ->
    $note = $(".note")
    id = $note.attr("data-id")

    isCtrlPressed = (e)->
      (e.ctrlKey && !e.metaKey) || (!e.ctrlKey && e.metaKey)

    isSaveKey = (e)->
      if isCtrlPressed(e)
        e.keyCode == 83
      else
        false

    attachGlobalKeyEvents = (note)->
      $('body').on 'keydown', (e)->
        if isSaveKey(e)
          e.preventDefault()
          note.saveContent()

    $.getJSON "#{id}.json", (data)->
      note = new App.Models.Note(data)
      editor = new App.Views.NoteEditorView(el:$(".editor"), model:note)
      $(window).bind "beforeunload", (event)->
        if note.dirty
          editor.save()
          "Quit?"
        else
          if note.isBlank()
            note.destroy()
            "Deleted!"
      attachGlobalKeyEvents(note)

    updateIndexPaneSize = -> $(".index", $note).height(($(window).height() - 40) + "px")
    $(window).bind "resize", (e)-> updateIndexPaneSize()
    updateIndexPaneSize()

  initNoteList: ->
    notes = new App.Collections.NoteList([])
    notes.url = '/my_notes'
    view = new App.Views.NoteListView(el: $('.notes'), collection: notes)
    preview = new App.Views.NotePreviewView(el: $('.note-preview'))
    view.on 'noteSelected', (id)-> preview.show(id)
    view.fetchMore()
