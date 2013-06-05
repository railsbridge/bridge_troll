describe("Section", function () {
  var view, model, attendees;
  beforeEach(function () {
    attendees = new Bridgetroll.Collections.Attendee([
      {role_id: Bridgetroll.Enums.Role.STUDENT, name: 'Othersection Rand', section_id: 11},
      {role_id: Bridgetroll.Enums.Role.STUDENT, name: 'Lana Lang', section_id: 401},
      {role_id: Bridgetroll.Enums.Role.VOLUNTEER, name: 'Grace Hopper', section_id: 401}
    ]);
    model = new Bridgetroll.Models.Section({
      id: 401,
      event_id: 191,
      name: "Wizard's Throne"
    });
    view = new Bridgetroll.Views.Section({
      section: model,
      attendees: attendees
    });
  });

  describe("onDestroyClick", function () {
    beforeEach(function () {
      spyOn(window, 'confirm').andReturn(true);
      view.onDestroyClick();
    });

    it("makes a request to destroy the session", function () {
      var request = this.server.requestFor('/events/191/sections/401');
      expect(request).not.toBeUndefined();
    });

    it("unsets section_id from all attendees", function () {
      expect(attendees.map(function (attendee) { return attendee.get('section_id') }).sort()).toEqual([undefined, undefined, 11].sort());
    });
  });

  describe("onTitleDoubleClick", function () {
    beforeEach(function () {
      spyOn(window, 'prompt').andReturn("Pirate's Bay");
      view.onTitleDoubleClick();
    });

    it("makes a request to update the name with the prompted value", function () {
      var request = this.server.requestFor('/events/191/sections/401');
      expect(request).not.toBeUndefined();
      expect(JSON.parse(request.requestBody).name).toEqual("Pirate's Bay");
    });

    describe("when the request completes", function () {
      beforeEach(function () {
        this.server.completeRequest('/events/191/sections/401', {
          id: 401,
          event_id: 191,
          name: "Pirate's Bay"
        });
      });

      it("re-renders with the new name", function () {
        expect(view.$('.title').text()).toContain("Pirate's Bay");
      });
    });
  });
});