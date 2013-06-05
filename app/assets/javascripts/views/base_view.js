Bridgetroll.Views.Base = Backbone.View.extend({
  postRender: $.noop,
  context: $.noop,

  initialize: function () {
    this.subViews = {};
  },

  render: function () {
    this.$el.empty();
    if (this.template) {
      var template = HandlebarsTemplates[this.template];
      this.$el.html(template(this.context()));
    }

    _.each(this.subViews, function (view, id) {
      view.render();
      this.$el.append(view.$el);
    }, this);

    this.postRender();
    this.delegateEvents();
  },

  destroy: function () {
    if (this.parent) {
      this.parent.removeSubview(this);
    }

    this.undelegateEvents();
    this.remove();
  },

  addSubview: function (view) {
    view.parent = this;
    this.subViews[view.cid] = view;
  },

  removeSubview: function (view) {
    delete this.subViews[view.cid];
  }
});
