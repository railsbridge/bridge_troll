Bridgetroll.Views.EditSection = (function () {
  return Bridgetroll.Dialogs.Base.extend({
    template: 'section_organizer/edit_section',

    events: {
      'click .submit': 'onSubmit'
    },

    levelName: function (level) {
      return {
        0: 'Unassigned',
        1: 'Blue',
        2: 'Green',
        3: 'Gold',
        4: 'Orange',
        5: 'Purple'
      }[level];
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

    formValues: function () {
      return {
        name: this.$('.section_name').val(),
        class_level: this.$('.class_level:checked').val()
      };
    },

    onSubmit: function () {
      this.model.save(this.formValues(), {wait: true}).success(_.bind(function () {
        $(this.el).modal('hide');
      }, this));
    }
  });
})();
