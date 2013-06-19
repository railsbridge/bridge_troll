describe("Section", function () {
  var view, model, attendees;
  beforeEach(function () {
    attendees = new Bridgetroll.Collections.Attendee([
      {id: 9,  event_id: 191, role_id: Bridgetroll.Enums.Role.STUDENT, full_name: 'Othersection Rand', section_id: 11},
      {id: 10, event_id: 191, role_id: Bridgetroll.Enums.Role.STUDENT, full_name: 'Lana Lang', class_level: 1, section_id: 401},
      {id: 10, event_id: 191, role_id: Bridgetroll.Enums.Role.STUDENT, full_name: 'Zana Zang', class_level: 1, section_id: 401},
      {id: 10, event_id: 191, role_id: Bridgetroll.Enums.Role.STUDENT, full_name: 'Student Person', class_level: 2, section_id: 401},
      {id: 11, event_id: 191, role_id: Bridgetroll.Enums.Role.VOLUNTEER, full_name: 'Grace Hopper', section_id: 401}
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

  describe("#attachPoint", function () {
    describe("when the section is for unassigned students", function () {
      beforeEach(function () {
        view.section.set('id', null);
      });

      it("returns level0", function () {
        expect(view.attachPoint()).toEqual('.bridgetroll-section-level.level0')
      });
    });

    describe("when the section is a real section", function () {
      it("returns the mode of the student class levels", function () {
        expect(view.attachPoint()).toEqual('.bridgetroll-section-level.level1')
      });
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
      expect(attendees.map(function (attendee) { return attendee.get('section_id') }).sort()).toEqual([null, null, 11].sort());
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
      expect(JSON.parse(request.requestBody).section.name).toEqual("Pirate's Bay");
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
        expect(view.$('.bridgetroll-section-title').text()).toContain("Pirate's Bay");
      });
    });
  });

  describe("#moveAttendeeToSection", function () {
    beforeEach(function () {
      view.moveAttendeeToSection(10);
    });

    it("makes a request to save the new section_id", function () {
      var request = this.server.requestFor('/events/191/attendees/10');
      expect(request).not.toBeUndefined();
      expect(JSON.parse(request.requestBody).attendee.section_id).toEqual(401);
    });

    describe("when the request completes successfully", function () {
      beforeEach(function () {
        spyOn(view, 'trigger');
        this.server.completeRequest('/events/191/attendees/10', {
          id: 10,
          event_id: 191,
          section_id: 401,
          full_name: "Lana Lang"
        });
      });

      it("triggers a section:changed event", function () {
        expect(view.trigger).toHaveBeenCalledWith('section:changed');
      });
    });
  });
});