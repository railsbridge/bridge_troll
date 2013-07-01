Bridgetroll.Views.Section = Bridgetroll.Views.Base.extend({
  className: 'bridgetroll-section',
  template: 'section_organizer/section',
  attachPoint: function () {
    var sectionClassPrefix = '.bridgetroll-section-level.level';
    if (this.section.get("id") === null) {
      return sectionClassPrefix + '0';
    }
    return sectionClassPrefix + this.findMode();
  },

  findMode: function () {
    var students = this.students();
    var mode = 0;
    var maxCount = 0;
    var counts = {};
    var levels = _.map(students, function (student) {
      return student.get('class_level');
    });

    _.each(levels, function (level) {
      if (counts[level]) {
        counts[level] += 1;
      } else {
        counts[level] = 1;
      }
      if (counts[level] > maxCount) {
        maxCount = counts[level];
        mode = level;
      }
    });
    return mode;
  },

  events: {
    'click .info': 'onInfoClick',
    'click .edit': 'onEditClick',
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
      students: _.pluck(this.students(), 'attributes'),
      volunteers: _.pluck(this.volunteers(), 'attributes'),
      destructable: !this.section.isUnassigned()
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
    attendee
      .save({section_id: this.section.get('id')})
      .success(_.bind(function () {
        this.trigger('section:changed');
      }, this))
      .error(function () {
        alert("Error reassigning attendee.");
      });
  },

  postRender: function () {
    this.$('.attendee').on('drag', this.attendeeDragging);
    this.$('.attendee').on('dragend', this.attendeeDropped);

    this.$el.drop(_.bind(function (el, dd) {
      var $attendee = $(dd.drag);
      this.moveAttendeeToSection($attendee.data('id'));
    }, this));
  },

  onInfoClick: function (e) {
    var id = $(e.target).closest('.attendee').data('id');
    var attendee = this.attendees.findWhere({id: id});
    var detailView = new Bridgetroll.Views.AttendeeDetail({model: attendee});
    detailView.showModally();
  },

  onEditClick: function () {
    if (this.section.isUnassigned()) {
      return;
    }

    var newName = window.prompt('Enter the new name for ' + this.section.get('name'), this.section.get('name') || '');
    if (newName) {
      this.section
        .save({name: newName})
        .success(_.bind(function () {
          this.render();
        }, this))
        .error(function () {
          alert("Error updating section.");
        });
    }
  },

  onDestroyClick: function () {
    var confirmed = window.confirm('Are you sure you want to destroy ' + this.section.get('name') + '?\n\nAll Students and Volunteers will return to being Unassigned.');
    if (confirmed) {
      _.invoke(this.students(), 'unassign');
      _.invoke(this.volunteers(), 'unassign');
      this.destroy();
      this.section.destroy();
    }
  }
});