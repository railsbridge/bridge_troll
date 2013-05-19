Bridgetroll.Views.Base = Backbone.View.extend({
  postRender: $.noop,
  context: $.noop,

  initialize: function () {
    this.subViews = [];
  },

  render: function () {
    this.$el.empty();
    if (this.template) {
      var template = HandlebarsTemplates[this.template];
      this.$el.html(template(this.context()));
    }

    this.postRender();
    this.delegateEvents();

    _.each(this.subViews, function (view) {
      view.render();
      this.$el.append(view.$el);
    }, this);
  }
});
