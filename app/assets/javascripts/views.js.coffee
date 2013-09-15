#
#
#
App.Views.isCtrlPressed = (e)->
  (e.ctrlKey && !e.metaKey) || (!e.ctrlKey && e.metaKey)

_.templateSettings =
  interpolate : /\{\{(.+?)\}\}/g
