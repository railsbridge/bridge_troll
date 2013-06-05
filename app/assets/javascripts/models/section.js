Bridgetroll.Models.Section = Backbone.Model.extend({
  urlRoot: function () {
    return '/events/' + this.get('event_id') + '/sections';
  }
});