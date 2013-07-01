Bridgetroll.Views.AttendeeDetail = (function () {
  return Bridgetroll.Views.Base.extend({
    className: 'bridgetroll-attendee-detail modal hide fade',
    template: 'section_organizer/attendee_detail',

    context: function () {
      return _.extend({
        student: this.model.get('role_id') == Bridgetroll.Enums.Role.STUDENT,
        volunteer: this.model.get('role_id') == Bridgetroll.Enums.Role.VOLUNTEER
      }, this.model.attributes);
    },

    showModally: function () {
      this.render();
      $('body').append(this.el);
      $(this.el).modal();

      $(this.el).on('hidden', _.bind(function () {
        this.destroy();
      }, this));
    }
  });
})();
