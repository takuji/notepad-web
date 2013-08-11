$ ->
  _.templateSettings =
    interpolate : /\{\{(.+?)\}\}/g

  if $(".editor").length
    App.Inits.initEditor()

  if $('.notes').length
    App.Inits.initNoteList()
