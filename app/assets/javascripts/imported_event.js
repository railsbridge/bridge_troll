(function () {
  ImportedEventPopover = {
    createPopoverTrigger: function () {
      return "<button class='imported-event-popover-trigger'>?</button>";
    },
    activatePopoverTrigger: function (container, imported_event_data) {
      if (!imported_event_data) {
        return;
      }

      var popoverContent = HandlebarsTemplates['imported_event_popover']({
        type: imported_event_data.type,
        student_event_url: imported_event_data.student_event.url,
        volunteer_event_url: imported_event_data.volunteer_event.url
      });
      $(container).find('.imported-event-popover-trigger')
        .popover({
          title: "Imported Event",
          trigger: 'focus',
          container: 'body',
          content: popoverContent,
          html: true
        })
        .on("show.bs.popover", function () {
          $(this).data("bs.popover").tip().css({maxWidth: "320px"})
        });
    }
  };
})();

