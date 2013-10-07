class App.Collections.NoteList extends Backbone.Collection
  page: 1
  _loading: false
  _hasNext: true
  model: App.Models.Note

  more: ->
    unless @_loading
      @_loading = true
      notes = new App.Collections.NoteList([])
      notes.url = @url
      notes.fetch
        data:
          page: @page
        success: (col, res, options)=>
          @page += 1
          console.log "page = #{@page}"
          @_hasNext = col.models.length > 0
          while col.models.length
            @.push(col.shift())
        error: (col, res, options)=>
          console.log 'Failed to fetch notes'
        complete: =>
          @_loading = false

  timestampOfLast: ->
    last = @last()
    if last
      last.get('created_at')
    else
      null

  hasNext: ->
    @_hasNext
