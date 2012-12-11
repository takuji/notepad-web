// Converts markdown to the index map
(function() {
  this.markdownToIndexMap = function(markdown) {
    var lines = markdown.split("\n");
    var lines_with_index = $.map(lines, function(line, i) {
      return {title:line, line: i + 1};
    });
    var indexes = $.grep(lines_with_index, function(title_and_index, i){
      return title_and_index.title.match("^#+");
    });
    return $.map(indexes, function(idx){
      idx.title.match(/^(#+)(.+)$/);
      var title = $.trim(RegExp.$2)
      var depth = RegExp.$1.length
      return $.extend(idx, {depth:depth, title:title});
    });
  };
})();
