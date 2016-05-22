window.resizeHeightMatchingItems = function ($element) {
  var items = $element.find('.js-match-height-item:visible');
  items.css('min-height', 0);

  var maxHeight = Math.max.apply(Math, _.map(items, function(item) {
    return $(item).outerHeight();
  }));
  items.css('min-height', maxHeight);
};

window.whenReady(function () {
  function setupHeightMatching ($element) {
    $(window).resize(_.debounce(function() {
      if ($(document).width() > 768) {
        resizeHeightMatchingItems($element);
      }
    }, 100));

    resizeHeightMatchingItems($element);
  }

  setupHeightMatching($('body'));
});
