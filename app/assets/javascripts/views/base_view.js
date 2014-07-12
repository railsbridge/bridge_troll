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
      if (view.skipRendering()) {
        return;
      }

      view.render();
      if (view.attachPoint) {
        this.$(view.attachPoint()).append(view.$el);
      } else {
        this.$el.append(view.$el);
      }
    }, this);

    this.postRender();
    this.delegateEvents();
  },

  skipRendering: $.noop,

  destroy: function () {
    _.invoke(this.subViews, 'destroy');

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
