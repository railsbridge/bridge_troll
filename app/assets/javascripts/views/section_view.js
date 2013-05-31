Bridgetroll.Views.Section = Bridgetroll.Views.Base.extend({
  className: 'bridgetroll-section',
  template: 'section_organizer/section',

  initialize: function (options) {
    this._super('initialize', arguments);

    this.section_id = options.section_id;

    this.title = options.title;
    this.attendees = options.attendees;
  },

  context: function () {
    return {
      title: this.title,
      students: _.invoke(this.students(), 'toJSON'),
      volunteers: _.invoke(this.volunteers(), 'toJSON')
    }
  },

  students: function () {
    var students = this.attendees.where({
      role_id: Bridgetroll.Enums.Role.STUDENT,
      section_id: this.section_id
    });
    return _.sortBy(students, function (student) {
      return student.get('class_level');
    });
  },

  volunteers: function () {
    return this.attendees.where({
      role_id: Bridgetroll.Enums.Role.VOLUNTEER,
      section_id: this.section_id
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
    attendee.set('section_id', this.section_id);
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
  }
});