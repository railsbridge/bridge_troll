Bridgetroll.Views.Section = Bridgetroll.Views.Base.extend({
  className: 'bridgetroll-section',
  template: 'section_organizer/section',

  events: {
    'sortreceive .students': 'studentAdded',
    'sortremove .students': 'studentRemoved'
  },

  initialize: function (options) {
    this._super('initialize', arguments);

    this.title = options.title;
    this.students = options.students;
  },

  context: function () {
    return {
      title: this.title,
      students: this.students.toJSON()
    }
  },

  studentAdded: $.noop,
  studentRemoved: $.noop,

  postRender: function () {
    this.$('.students').sortable({connectWith: '.bridgetroll-section .students'});
  }
});