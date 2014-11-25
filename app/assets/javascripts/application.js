// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui/datepicker
//= require bootstrap/transition
//= require bootstrap/modal
//= require bootstrap/tooltip
//= require bootstrap/popover
//= require select2
//= require handlebars.runtime
//= require underscore
//= require gmaps/google
//= require backbone
//= require backbone-super
//= require masonry/jquery.masonry
//= require jquery.event.drag
//= require jquery.event.drop
//= require bridgetroll
//= require_tree ../templates
//= require_tree ./enums
//= require_tree ./models
//= require_tree ./collections
//= require ./views/base_view
//= require_tree ./views
//= require ./dialogs/base_dialog
//= require_tree ./dialogs
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require_tree .
//= require jquery_nested_form

$(document).ready(function () {
  if ($(window).height() < $('html').height()) {
    $('footer').show();
  }

  function matchHeights ($element) {
    var maxHeight;
    var items = $element.find('.js-match-height-item');
    items.css('height', 'auto');
    maxHeight = Math.max.apply(Math, _.map(items, function(item) {
      return $(item).outerHeight();
    }));
    items.css({ 'height': maxHeight });
  }

  $(window).resize(function() {
    if ($(document).width() > 768) {
      matchHeights($('.upcoming-events'));
    }
  });

  matchHeights($('.upcoming-events'));
});
