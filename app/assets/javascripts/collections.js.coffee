class App.Collections.NoteList extends Backbone.Collection
  page: 1
  _hasNext: true
  model: App.Models.Note

  more: ->
    notes = new App.Collections.NoteList([])
    notes.url = @url
    notes.fetch
      data:
        page: @page
      success: (col, res, options)=>
        @page += 1
        @_hasNext = col.models.length > 0
        while col.models.length
          @.push(col.shift())
      error: (col, res, options)=>
        console.log 'Failed to fetch notes'

  timestampOfLast: ->
    last = @last()
    if last
      last.get('created_at')
    else
      null

  hasNext: ->
    @_hasNext
