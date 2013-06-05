Bridgetroll.Views.Section = Bridgetroll.Views.Base.extend({
  className: 'bridgetroll-section',
  template: 'section_organizer/section',

  events: {
    'dblclick .title': 'onTitleDoubleClick',
    'click .destroy': 'onDestroyClick'
  },

  initialize: function (options) {
    this._super('initialize', arguments);

    this.section = options.section;

    this.attendees = options.attendees;
  },

  context: function () {
    return {
      title: this.section.get('name'),
      students: _.invoke(this.students(), 'toJSON'),
      volunteers: _.invoke(this.volunteers(), 'toJSON'),
      destructable: this.section.get('id') !== undefined
    }
  },

  students: function () {
    var students = this.attendees.where({
      role_id: Bridgetroll.Enums.Role.STUDENT,
      section_id: this.section.get('id')
    });
    return _.sortBy(students, function (student) {
      return student.get('class_level');
    });
  },

  volunteers: function () {
    return this.attendees.where({
      role_id: Bridgetroll.Enums.Role.VOLUNTEER,
      section_id: this.section.get('id')
    });
  },

  attendeeDragging: function (el, dd) {
    var $attendee = $(dd.drag);
    $attendee.addClass('dragging');
    $attendee.css({
      top: dd.offsetY,
      left: dd.offsetX
    });
  },

  attendeeDropped: function (el, dd) {
    $(dd.drag).removeClass('dragging');
    $(dd.drag).css({
      top: '',
      left: ''
    });
  },

  moveAttendeeToSection: function (attendee_id) {
    var attendee = this.attendees.where({id: attendee_id})[0];
    attendee.set('section_id', this.section.get('id'));
    this.trigger('section:changed');
  },

  postRender: function () {
    this.$('.attendee').on('drag', this.attendeeDragging);
    this.$('.attendee').on('dragend', this.attendeeDropped);

    var self = this;
    this.$el.drop(function (el, dd) {
      var $attendee = $(dd.drag);
      self.moveAttendeeToSection($attendee.data('id'));
    });
  },

  onTitleDoubleClick: function () {
    var newName = window.prompt('Enter the new name for ' + this.section.get('name'));
    if (newName) {
      this.section.set('name', newName);
      this.section.save().success(_.bind(function () {
        this.render();
      }, this));
    }
  },

  onDestroyClick: function () {
    var confirmed = window.confirm('Are you sure you want to destroy ' + this.section.get('name') + '?\n\nAll Students and Volunteers will return to being Unassigned.');
    if (confirmed) {
      _.each(this.students(), function (student) {
        student.set('section_id', undefined);
      });
      _.each(this.volunteers(), function (volunteer) {
        volunteer.set('section_id', undefined);
      });
      this.destroy();
      this.section.destroy();
    }
  }
});