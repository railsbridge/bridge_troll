Bridgetroll.Views.AttendeeDetail = (function () {
  return Bridgetroll.Dialogs.Base.extend({
    className: 'bridgetroll-attendee-detail modal hide fade',
    template: 'section_organizer/attendee_detail',

    context: function () {
      return _.extend({
        student: this.model.get('role_id') == Bridgetroll.Enums.Role.STUDENT,
        volunteer: this.model.get('role_id') == Bridgetroll.Enums.Role.VOLUNTEER,
        organizer: this.model.get('role_id') == Bridgetroll.Enums.Role.ORGANIZER
      }, this.model.attributes);
    }
  });
})();
