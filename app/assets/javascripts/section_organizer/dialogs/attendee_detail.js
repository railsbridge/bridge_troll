Bridgetroll.Views.AttendeeDetail = (function () {
  return Bridgetroll.Dialogs.Base.extend({
    className: function () {
      return this._super('className', arguments) + ' bridgetroll-attendee-detail';
    },
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
