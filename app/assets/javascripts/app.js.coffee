$ ->
  _.templateSettings =
    interpolate : /\{\{(.+?)\}\}/g

  if $(".editor").length
    App.Inits.initEditor()

  if $('.note-list-page').length
    App.Inits.initNoteList()
