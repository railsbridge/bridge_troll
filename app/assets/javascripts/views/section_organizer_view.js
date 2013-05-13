Bridgetroll.Views.SectionOrganizer = Backbone.View.extend({
  initialize: function (options) {
    this.subViews = [];
    this.students = options && options.students;

    this.students.each(function (student) {
      this.addStudent(student);
    }, this);
  },

  render: function () {
    this.$el.empty();

    _.each(this.subViews, function (view) {
      view.render();
      this.$el.append(view.$el);
    }, this);
  },

  addStudent: function (student) {
    var studentView = new Bridgetroll.Views.Student({model: student});
    this.subViews.push(studentView);
    this.render();
  },

  addSection: function () {
    var section = new Bridgetroll.Views.Section();
    this.subViews.push(section);
    this.render();
  }
});
