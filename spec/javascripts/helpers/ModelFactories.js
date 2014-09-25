Factories = (function () {
  Role = Bridgetroll.Enums.Role;

  var id = 9;
  return {
    attendee: function (attrs) {
      id++;
      return _.extend({id: id, event_id: 191}, attrs);
    },
    volunteer: function (attrs) {
      return _.extend(this.attendee({role_id: Role.VOLUNTEER}), attrs);
    },
    student: function (attrs) {
      return _.extend(this.attendee({role_id: Role.STUDENT}), attrs);
    }
  };
})();