Bridgetroll.Models.Attendee = Backbone.Model.extend({
  urlRoot: function () {
    return '/events/' + this.get('event_id') + '/attendees';
  },

  toJSON: function () {
    return {
      rsvp: this.attributes
    };
  },

  unassign: function () {
    this.set('section_id', null);
  }
});