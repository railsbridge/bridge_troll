Bridgetroll.Views.Section = Backbone.View.extend({
  className: 'bridgetroll-section',

  render: function () {
    this.$el.empty();
    this.$el.append('i am a section');
  }
});