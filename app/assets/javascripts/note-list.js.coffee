$ ->
  if $(".notes").length
    _.templateSettings =
      interpolate : /\{\{(.+?)\}\}/g

    notesState =
      oldest: null

    $notes = $('.notes')
    $list = $('<ul>')
    cache = {}

    $notes.append($list)

    loadNotes = (state)->
      d = new $.Deferred()
      t = if state.oldest? then state.oldest.id else null
      $.getJSON('/my_notes.json', {t: t}, (notes)->
        template = _.template($("#templates > .note-index").html())
        noteTemplates = _.map(notes, (note)-> template(note))
        _.each noteTemplates, (li)-> $list.append(li)
        oldestNote = _.last(notes)
        newState = _.extend(state, oldest: oldestNote)
        d.resolve(newState)
      )
      d.promise()

    loadNotes(notesState)
      .done (newState)->
        notesState = newState
        console.log newState


    $notes.on("mouseenter", "li", (e)->
      id = $(this).attr("data-id")
      if cache[id]
        $(".note-preview").html(cache[id])
      else
        $(".note-preview").load("/my_notes/#{id}/content", (responseText)->
          cache[id] = responseText
        )
    ).on("click", "li", (e)->
      id = $(this).attr("data-id")
      location.href = "/my_notes/#{id}"
    )

    $('.more').on('click', ->
      loadNotes(notesState)
        .done (newState)-> notesState = newState
    )

