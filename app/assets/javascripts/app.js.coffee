$ ->
  _.templateSettings =
    interpolate : /\{\{(.+?)\}\}/g

  $.cookie.defaults.path = '/'

  if $(".editor").length
    App.Inits.initEditor()

  if $('.note-list-page').length
    App.Inits.initNoteList()
