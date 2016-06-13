Bridgetroll.Models.Attendee = Backbone.Model.extend({
  initialize: function (options) {
    this.set('teaching_preference_description', this.teachingPreferenceDescription(options));
  },

  teachingPreferenceDescription: function (options) {
    if (options.role_id != Bridgetroll.Enums.Role.VOLUNTEER) {
      return;
    }

    if (options.teaching) {
      if (options.taing) {
        return 'Teaching or TAing';
      } else {
        return 'Teaching';
      }
    } else {
      if (options.taing) {
        return 'TAing';
      } else {
        return 'Non-teaching volunteer';
      }
    }
  },

  urlRoot: function () {
    return '/events/' + this.get('event_id') + '/attendees';
  },

  toJSON: function () {
    return {
      attendee: this.attributes
    };
  },

  unassign: function () {
    this.set('section_id', null);
  },

  volunteerLetter: function () {
    if (this.get('teaching') && this.get('taing')) {
      return '?';
    } else if (this.get('teaching')) {
      return 'T';
    } else if (this.get('taing')) {
      return 't';
    } else {
      return 'x';
    }
  },

  checkedInTo: function (sessionId) {
    return _.include(this.get('checked_in_session_ids'), sessionId);
  }
});