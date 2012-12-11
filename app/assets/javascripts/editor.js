$(function() {
  if ($(".editor").length) {
    // エディタの中身が変わったことを
    $editor = $(".editor");

    function toIndexList(indexes) {
      // [index]
      var list = $("<ul>");
      var elms =  $.map(indexes, function(index) {
        return toLi(index);
      });
      $.each(elms, function(i) {
        list.append(this);
      });
      return list;
    }

    function toLi(index) {
      var li = $("<li>");
      li.attr("data-line", index.line);
      li.attr("data-depth", index.depth).text(index.title);
      return li;
    }

    function lineCount($textarea) {
      return $textarea.val().split("\n").length;
    }

    function goToLine($textArea, n) {
      var y = Math.floor($textArea.offset().top + ($textArea.height() * n) / lineCount($textArea));
      window.scrollTo(0, y);
    }

    $textarea = $("textarea", $editor);

    $textarea.keyup(function() {
      var indexes = markdownToIndexMap($(this).val());
      var indexList = toIndexList(indexes);
      $(".index").html(indexList);
    }).autosize();

    $(".index ul li").live("click", function() {
      var lineNo = $(this).attr("data-line");
      goToLine($textarea, parseInt(lineNo));
    });

  }
});
