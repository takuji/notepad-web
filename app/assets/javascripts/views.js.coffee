#
#
#
App.Views.isCtrlPressed = (e)->
  (e.ctrlKey && !e.metaKey) || (!e.ctrlKey && e.metaKey)

App.Views.isShiftPressed = (e)->
  e.shiftKey

_.templateSettings =
  interpolate : /\{\{(.+?)\}\}/g
