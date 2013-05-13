Bridgetroll.Views.Student = Backbone.View.extend({
  className: 'bridgetroll-student',

  render: function () {
    this.$el.empty();
    this.$el.append(this.model.get('name'));
  }
});