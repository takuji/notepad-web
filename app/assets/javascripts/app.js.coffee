$ ->
  $("body:has(.note)").css("backgroundColor": "#e4e4e4")

  if $(".editor").length
    App.Inits.initEditor()
