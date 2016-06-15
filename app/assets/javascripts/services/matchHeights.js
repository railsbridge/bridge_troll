window.resizeHeightMatchingItems = function ($element) {
  var items = $element.find('.js-match-height-item:not(.hide)');
  items.css('min-height', 0);
  var $items = items.map(function (ix, item) { return $(item); });

  var itemsByTop = {};
  _.each($items, function($item, ix) {
    var top = $item.offset().top;
    itemsByTop[top] = itemsByTop[top] || [];
    itemsByTop[top].push($item);
  });

  _.each(itemsByTop, function (items, top) {
    var maxHeight = Math.max.apply(Math, _.map(items, function($item) {
      return $item.outerHeight();
    }));
    _.each(items, function($item, ix) {
      $item.css('min-height', maxHeight);
    });
  });
};

window.whenReady(function () {
  function setupHeightMatching ($element) {
    $(window).resize(_.debounce(function() {
      if ($(document).width() > 768) {
        resizeHeightMatchingItems($element);
      }
    }, 100));

    setTimeout(function () {
      resizeHeightMatchingItems($element);
    });
  }

  setupHeightMatching($('body'));
});
