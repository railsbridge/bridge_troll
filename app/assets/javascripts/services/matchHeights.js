$(document).ready(function () {
  function matchHeights ($element) {
    var items = $element.find('.js-match-height-item');
    items.css('min-height', 0);

    var maxHeight = Math.max.apply(Math, _.map(items, function(item) {
      return $(item).outerHeight();
    }));
    items.css('min-height', maxHeight);
  }

  function setupHeightMatching ($element) {
    $(window).resize(_.debounce(function() {
      if ($(document).width() > 768) {
        matchHeights($element);
      }
    }, 100));

    matchHeights($element);
  }

  setupHeightMatching($('body'));
});
