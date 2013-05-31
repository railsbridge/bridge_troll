Bridgetroll.Views.SectionOrganizer = Bridgetroll.Views.Base.extend({
  template: 'section_organizer/section_organizer',

  events: {
    'click .add-section': 'addSection'
  },

  initialize: function (options) {
    this._super('initialize', arguments);
    this.attendees = options.attendees;

    this.listenTo(this.attendees, 'change', this.render);

    var section = new Bridgetroll.Views.Section({
      title: 'Unsorted Attendees',
      attendees: options.attendees
    });

    this.subViews.push(section);
    this.listenTo(section, 'section:changed', this.render);
    this.render();
  },

  addSection: function () {
    var section = new Bridgetroll.Views.Section({
      title: 'New Section',
      section_id: _.uniqueId('s'),
      attendees: this.attendees
    });

    this.subViews.push(section);
    this.listenTo(section, 'section:changed', this.render);

    this.render();
  }
});
