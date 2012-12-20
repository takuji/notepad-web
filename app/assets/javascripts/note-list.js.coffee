$ ->
  if $(".notes").length
    _.templateSettings =
      interpolate : /\{\{(.+?)\}\}/g

    $.getJSON("/my_notes.json", (notes)->
      template = _.template($("#templates > .note-index").html())
      list = $("<ul>")
      _.each(_.map(notes, (note)-> template(note)), (li)->
        list.append(li)
      )
      $(".notes").html(list)
    )

    cache = {}

    $(".notes").on("mouseenter", "li", (e)->
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
