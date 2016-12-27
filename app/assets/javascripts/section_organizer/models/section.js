Bridgetroll.Models.Section = Backbone.Model.extend({
  urlRoot: function () {
    return '/events/' + this.get('event_id') + '/sections';
  },

  toJSON: function () {
    return {
      section: this.attributes
    };
  },

  classLevel: function () {
    return parseInt(this.get('class_level'), 10);
  },

  isUnassigned: function () {
    return this.get('id') === null;
  }
});