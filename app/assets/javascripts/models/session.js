Bridgetroll.Models.Session = Backbone.Model.extend({
  toJSON: function () {
    return this.attributes;
  }
});