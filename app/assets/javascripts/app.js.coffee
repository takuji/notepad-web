$ ->
  $("body:has(.note)").css("backgroundColor": "#e4e4e4")

  _.templateSettings =
    interpolate : /\{\{(.+?)\}\}/g

  if $(".editor").length
    App.Inits.initEditor()

  if $('.notes').length
    App.Inits.initNoteList()
