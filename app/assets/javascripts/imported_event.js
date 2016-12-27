(function () {
  function createButton(text, attributes) {
    var button = document.createElement('button');
    button.innerHTML = text;
    _.each(attributes, function (value, key) {
      button.setAttribute(key, value);
    });
    return button.outerHTML;
  }

  ImportedEventPopover = {
    createPopoverTrigger: function (imported_event_data) {
      var popoverContent = HandlebarsTemplates['imported_event_popover']({
        type: imported_event_data.type,
        student_event_url: imported_event_data.student_event.url,
        volunteer_event_url: imported_event_data.volunteer_event.url
      });
      return createButton('?', {
        'data-toggle': "popover",
        'data-title': "Imported Event",
        'data-trigger': 'focus',
        'data-container': 'body',
        'data-content': popoverContent,
        'data-html': true,
        'class': 'imported-event-popover-trigger'
      });
    },
    activatePopoverTrigger: function (container) {
      $(container).find('[data-toggle="popover"]')
        .popover()
        .on("show.bs.popover", function () {
          $(this).data("bs.popover").tip().css({maxWidth: "320px"})
        });
    }
  };
})();

