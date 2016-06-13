Bridgetroll.Views.SectionOrganizer = (function () {
  function addSectionView(section) {
    var sectionView = new Bridgetroll.Views.Section({
      section: section,
      attendees: this.attendees,
      selectedSession: this.selectedSession,
      displayProperties: this.displayProperties,
      levels: this.levels
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
      'click .show-help': 'onHelpClick',
      'click .show-os': 'onShowOSClick',
      'click .projector-mode': 'onProjectorModeClick',
      'click .poll-for-changes': 'onPollForChangesClick',
      'click .auto-arrange-choices': 'onAutoArrangeChoicesClick',
      'click .section-checkin-highlight-legend .dropdown': 'onSectionRsvpHighlightLegendClick',
      'click .section-highlight-link': 'onSectionHighlightLinkClick'
    },

    initialize: function (options) {
      this._super('initialize', arguments);
      this.event_id = options.event_id;
      this.attendees = options.attendees;
      this.sections = options.sections;
      this.sessions = options.sessions;
      this.upcoming = options.upcoming;
      this.levels = options.levels;

      this.selectedSession = this.sessions.last().clone();
      this.displayProperties = new Backbone.Model();

      this.showOS = false;
      this.projectorMode = false;

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

    checkinCounts: function () {
      return {
        students: {
          checkedIn: _.filter(this.students(), _.bind(function (a) {
            return a.checkedInTo(this.selectedSession.get('id'))
          }, this)).length,
          total: this.students().length
        },
        volunteers: {
          checkedIn: _.filter(this.volunteers(), _.bind(function (a) {
            return a.checkedInTo(this.selectedSession.get('id'))
          }, this)).length,
          total: this.volunteers().length
        }
      }
    },

    context: function () {
      return {
        hasSections: this.sections.length > 0,
        projectorMode: this.projectorMode,
        upcoming: this.upcoming,
        showOS: this.showOS,
        polling: this.poller.polling(),
        sessions: this.sessions.toJSON(),
        selectedSession: this.selectedSession.toJSON(),
        checkinCounts: this.checkinCounts(),
        levels: this.levels
      };
    },

    postRender: function () {
      this.$el.off();
      this.$el.on('mousemove', _.throttle(_.bind(function () {
        this.poller.stallPolling();
      }, this), 100));
      if (this.displayProperties.get('masonry')) {
        this.$el.find('.masonry-container').masonry({
          itemSelector: '.bridgetroll-section',
          gutter: 10
        });
      }
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

    onHelpClick: function () {
      var dialog = new Bridgetroll.Views.HelpDialog();
      dialog.showModally();
    },

    onShowOSClick: function () {
      this.showOS = !this.showOS;
      this.render();
      this.$el.toggleClass('showing-os', this.showOS);
    },

    onProjectorModeClick: function () {
      this.projectorMode = !this.projectorMode;
      this.displayProperties.set('masonry', this.projectorMode);
      $('body').toggleClass('section-organizer-projector-mode', this.projectorMode);
      this.render();
    },

    onPollForChangesClick: function () {
      this.poller.togglePolling();
      this.render();
    },

    onAutoArrangeChoicesClick: function () {
      var choicesView = new Bridgetroll.Views.AutoArrangeChoices({
        sessions: this.sessions,
        volunteers: this.volunteers(),
        students: this.students()
      });
      choicesView.showModally();
    },

    onSectionRsvpHighlightLegendClick: function (e) {
      $(e.currentTarget).toggleClass('open');
      return false;
    },

    onSectionHighlightLinkClick: function (e) {
      $('.section-checkin-highlight-legend .dropdown').toggleClass('open');
      this.selectedSession.set(this.sessions.where({id: $(e.target).data('id')})[0].attributes);
      this.render();
      return false;
    }
  });
})();
