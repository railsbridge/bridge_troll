(function () {
  ImportedEventPopover = {
    createPopoverTrigger: function (eventId) {
      return "<button class='imported-event-popover-trigger' data-event-id=" + eventId + ">?</button>";
    },
    activatePopoverTriggers: function (container) {
      $(container || 'body').find('.imported-event-popover-trigger:not(.active)')
        .popover({
          title: "Imported Event",
          trigger: 'focus',
          container: 'body',
          content: 'Loading...',
          html: true
        })
        .addClass('active')
        .on("show.bs.popover", function () {
          var popover = $(this).data("bs.popover").tip();
          popover.css({maxWidth: "320px", minHeight: "100px"});

          $.getJSON('/events/' + $(this).data('eventId') + '.json', (function (event) {
            var popoverContent = HandlebarsTemplates['imported_event_popover']({
              type: event.imported_event_data.type,
              student_event_url: event.imported_event_data.student_event.url,
              volunteer_event_url: event.imported_event_data.volunteer_event.url
            });
            popover.find('.popover-content').html(popoverContent);
          }).bind(this));
        });
    }
  };
})();

