Bridgetroll.Views.EditSection = (function () {
  return Bridgetroll.Dialogs.Base.extend({
    template: 'section_organizer/edit_section',

    events: {
      'click .submit': 'onSubmit',
      'submit form': 'onSubmit'
    },

    initialize: function (options) {
      this._super('initialize', arguments);

      this.levels = options.levels;
    },

    levelName: function (level) {
      if (level == 0) {
        return 'Unassigned';
      } else {
        return this.levels[level-1].color;
      }
    },

    context: function () {
      return {
        section_name: this.model.get('name'),
        options: _.map([0, 1, 2, 3, 4, 5], function (n) {
          return {
            name: this.levelName(n),
            value: n,
            selected: parseInt(this.model.get('class_level'), 10) == n
          };
        }, this)
      }
    },

    postRender: function () {
      this.$('.section_name').focus();
    },

    formValues: function () {
      return {
        name: this.$('.section_name').val(),
        class_level: this.$('.class_level:checked').val()
      };
    },

    onSubmit: function (event) {
      event && event.preventDefault();
      this.model.save(this.formValues(), {wait: true}).success(_.bind(function () {
        $(this.el).modal('hide');
      }, this));
    }
  });
})();
