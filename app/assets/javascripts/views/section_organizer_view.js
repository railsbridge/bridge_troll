Bridgetroll.Views.SectionOrganizer = (function () {
  function addSectionView(section) {
    var sectionView = new Bridgetroll.Views.Section({
      section: section,
      attendees: this.attendees,
      workshopSessionId: _.last(this.sessions).id
    });

    this.addSubview(sectionView);
    this.listenTo(sectionView, 'section:changed', this.render);
    this.listenTo(sectionView, 'attendee_drag:start', function () {
      this.poller.suspendPolling();
    });
    this.listenTo(sectionView, 'attendee_drag:stop', function () {
      this.poller.resumePolling();
    });

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
      this.sessions = options.sessions;

      this.showOS = false;
      this.showUnassigned = true;

      this.unsortedSection = new Bridgetroll.Models.Section({
        id: null,
        name: 'Unsorted Attendees'
      });

      this.listenTo(this.attendees, 'add remove change', this.render);
      this.listenTo(this.sections, 'add remove', this.updateSectionViewsAndRender);
      this.listenTo(this.sections, 'change', this.render);

      this.listenTo(this.attendees, 'add remove change', function () {
        this.poller.resetPollingInterval();
      });
      this.listenTo(this.sections, 'add remove change', function () {
        this.poller.resetPollingInterval();
      });

      this.poller = new Bridgetroll.Services.Poller({
        pollUrl: 'organize_sections.json',
        afterPoll: _.bind(function (json) {
          this.sections.set(json['sections']);
          this.attendees.set(json['attendees']);
          this.render();
        }, this)
      });

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

    volunteers: function () {
      return this.attendees.where({role_id: Bridgetroll.Enums.Role.VOLUNTEER})
    },

    students: function () {
      return this.attendees.where({role_id: Bridgetroll.Enums.Role.STUDENT})
    },

    context: function () {
      function checkedIn (collection) {
        return collection.filter(function(a) { return a.get('checkins_count') > 0 });
      }

      var sessionsWithCheckinCounts = _.map(this.sessions, _.bind(function (session) {
        session.checkedInVolunteers = checkedIn(this.volunteers()).filter(function (a) {
          return _.include(a.get('checked_in_session_ids'), session.id);
        }).length;
        session.checkedInStudents = checkedIn(this.students()).filter(function (a) {
          return _.include(a.get('checked_in_session_ids'), session.id);
        }).length;

        return session;
      }, this));

      return {
        hasSections: this.sections.length > 0,
        showUnassigned: this.showUnassigned,
        showOS: this.showOS,
        sessions: sessionsWithCheckinCounts,
        polling: this.poller.polling(),
        checkedInCounts: {
          indiscriminate: {
            volunteers: this.volunteers().length,
            students: this.students().length
          },
          any: {
            volunteers: checkedIn(this.volunteers()).length,
            students: checkedIn(this.students()).length
          }
        }
      };
    },

    postRender: function () {
      this.$el.off();
      this.$el.on('mousemove', _.throttle(_.bind(function () {
        this.poller.stallPolling();
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
      this.poller.togglePolling();
      this.render();
    }
  });
})();
