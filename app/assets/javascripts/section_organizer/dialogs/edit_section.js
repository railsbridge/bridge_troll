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

    context: function () {
      var levels = [{index: 0}].concat(this.levels);
      return {
        section_name: this.model.get('name'),
        options: _.map(levels, function (level) {
          return {
            name: level.color || 'Unassigned',
            value: level.index,
            selected: this.model.classLevel() == level.index
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
