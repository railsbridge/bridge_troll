Bridgetroll.Models.Session = Backbone.Model.extend({
  toJSON: function () {
    return this.attributes;
  },

  checkedInVolunteers: function (volunteers) {
    return volunteers.filter(_.bind(function (a) {
      return _.include(a.get('checked_in_session_ids'), this.get('id'));
    }, this)).length;
  },

  checkedInStudents: function (students) {
    return students.filter(_.bind(function (a) {
      return _.include(a.get('checked_in_session_ids'), this.get('id'));
    }, this)).length;
  }
});