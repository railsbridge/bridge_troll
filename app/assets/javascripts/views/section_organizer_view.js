Bridgetroll.Views.SectionOrganizer = (function () {
  function addSectionView(section) {
    var sectionView = new Bridgetroll.Views.Section({
      section: section,
      attendees: this.attendees
    });

    this.addSubview(sectionView);
    this.listenTo(sectionView, 'section:changed', this.render);
    this.listenTo(sectionView, 'attendee_drag:start', this.dragStarted);
    this.listenTo(sectionView, 'attendee_drag:stop', this.dragEnded);

    if (section.get('id')) {
      this.sections.add(section);
    }
  }

  return Bridgetroll.Views.Base.extend({
    template: 'section_organizer/section_organizer',

    events: {
      'click .add-section': 'onAddSectionClick',
      'click .show-os': 'onShowOSClick',
      'click .show-unassigned': 'onShowUnassignedClick',
      'click .poll-for-changes': 'onPollForChangesClick'
    },

    initialize: function (options) {
      this._super('initialize', arguments);
      this.event_id = options.event_id;
      this.attendees = options.attendees;
      this.sections = options.sections;

      this.showOS = false;
      this.showUnassigned = true;

      this.resetPollingInterval();

      this.unsortedSection = new Bridgetroll.Models.Section({
        id: null,
        name: 'Unsorted Attendees'
      });

      this.listenTo(this.attendees, 'add remove change', this.render);
      this.listenTo(this.sections, 'add remove', this.updateSectionViewsAndRender);
      this.listenTo(this.sections, 'change', this.render);

      this.listenTo(this.attendees, 'add remove change', this.resetPollingInterval);
      this.listenTo(this.sections, 'add remove change', this.resetPollingInterval);

      this.updateSectionViewsAndRender();
    },

    updateSectionViewsAndRender: function () {
      this.updateSectionViews();
      this.render();
    },

    updateSectionViews: function () {
      _.invoke(this.subViews, 'destroy');

      addSectionView.call(this, this.unsortedSection);

      this.sections.each(_.bind(function (section) {
        addSectionView.call(this, section);
      }, this));
      this.render();
    },

    context: function () {
      return {
        showUnassigned: this.showUnassigned,
        showOS: this.showOS,
        polling: !!this.pollTimer
      };
    },

    postRender: function () {
      this.$el.off();
      this.$el.on('mousemove', _.throttle(_.bind(function () {
        if (this.pollTimer) {
          clearTimeout(this.pollTimer);
          this.startPolling(5);
        }
      }, this), 100));
    },

    onAddSectionClick: function () {
      var section = new Bridgetroll.Models.Section({event_id: this.event_id});
      section
        .save()
        .success(_.bind(function (sectionJson) {
          var section = new Bridgetroll.Models.Section(sectionJson);
          addSectionView.call(this, section);
        }, this))
        .error(function () {
          alert('Error creating section.')
        });
    },

    onShowOSClick: function () {
      this.showOS = !this.showOS;
      this.render();
      this.$el.toggleClass('showing-os', this.showOS);
    },

    onShowUnassignedClick: function () {
      this.showUnassigned = !this.showUnassigned;
      this.render();
      this.$el.toggleClass('showing-unassigned', this.showUnassigned);
    },

    onPollForChangesClick: function () {
      if (this.pollTimer) {
        this.stopPolling();
      } else {
        this.startPolling();
      }
      this.render();
    },

    startPolling: function (interval) {
      interval = interval || this.pollingInterval;
      var refreshData = _.bind(function () {
        $.ajax({
          url: 'organize_sections.json',
          success: _.bind(function (json) {
            if (!this.dragging) {
              this.pollsSinceLastIntervalReset += 1;
              this.sections.set(json['sections']);
              this.attendees.set(json['attendees']);
              this.render();
            }
            this.pollTimer = setTimeout(refreshData, this.pollingInterval * 1000);
            this.computeNewPollingInterval();
          }, this)
        });
      }, this);
      this.pollTimer = setTimeout(refreshData, interval * 1000);
    },

    stopPolling: function () {
      clearTimeout(this.pollTimer);
      this.pollTimer = undefined;
    },

    computeNewPollingInterval: function () {
      var intervals = [2, 5, 15, 30, 60];
      if (this.pollsSinceLastIntervalReset > 5) {
        var existingIntervalIndex = intervals.indexOf(this.pollingInterval);
        if (existingIntervalIndex < intervals.length - 1) {
          this.pollsSinceLastIntervalReset = 0;
          this.pollingInterval = intervals[existingIntervalIndex + 1];
        }
      }
    },

    resetPollingInterval: function () {
      this.pollsSinceLastIntervalReset = 0;
      this.pollingInterval = 1;
    },

    dragStarted: function () {
      this.dragging = true;
    },

    dragEnded: function () {
      this.dragging = false;
    }
  });
})();
