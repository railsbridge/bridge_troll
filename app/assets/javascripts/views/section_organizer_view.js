Bridgetroll.Views.SectionOrganizer = (function () {
  function addSectionView(section) {
    var sectionView = new Bridgetroll.Views.Section({
      section: section,
      attendees: this.attendees
    });

    this.addSubview(sectionView);
    this.listenTo(sectionView, 'section:changed', this.render);

    if (section.get('id')) {
      this.sections.add(section);
    }
  }

  return Bridgetroll.Views.Base.extend({
    template: 'section_organizer/section_organizer',

    events: {
      'click .add-section': 'onAddSectionClick',
      'click .show-os': 'onShowOSClick'
    },

    initialize: function (options) {
      this._super('initialize', arguments);
      this.event_id = options.event_id;
      this.attendees = options.attendees;
      this.sections = options.sections;

      this.listenTo(this.attendees, 'change', this.render);

      this.unsortedSection = new Bridgetroll.Models.Section({
        id: null,
        name: 'Unsorted Attendees'
      });
      addSectionView.call(this, this.unsortedSection);

      this.sections.each(_.bind(function (section) {
        addSectionView.call(this, section);
      }, this));
      this.listenTo(this.sections, 'add remove', this.render);

      this.render();
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
      this.$el.toggleClass('showing-os');
      if (this.$el.hasClass('showing-os')) {
        this.$('.show-os').text('Hide Student OS');
      } else {
        this.$('.show-os').text('Show Student OS');
      }
    }
  });
})();
