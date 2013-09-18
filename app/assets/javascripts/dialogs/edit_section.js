Bridgetroll.Views.EditSection = (function () {
  return Bridgetroll.Dialogs.Base.extend({
    className: 'modal hide fade',
    template: 'section_organizer/edit_section',

    events: {
      'click .submit': 'onSubmit'
    },

    context: function () {
      return {
        section_name: this.model.get('name'),
        class_level: this.model.get('class_level')
      }
    },

    formValues: function () {
      return {
        name: this.$('.section_name').val(),
        class_level: this.$('.class_level').val()
      };
    },

    onSubmit: function () {
      this.model.save(this.formValues(), {wait: true}).success(_.bind(function () {
        if (this.options.success) {
          this.options.success();
        }
        $(this.el).modal('hide');
      }, this));
    }
  });
})();
