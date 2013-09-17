describe("Section", function () {
  var view, model, attendees;
  beforeEach(function () {
    attendees = new Bridgetroll.Collections.Attendee([
      {id: 9,  event_id: 191, role_id: Bridgetroll.Enums.Role.STUDENT, full_name: 'Othersection Rand', section_id: 11},
      {id: 10, event_id: 191, role_id: Bridgetroll.Enums.Role.STUDENT, full_name: 'Lana Lang', class_level: 1, section_id: 401},
      {id: 11, event_id: 191, role_id: Bridgetroll.Enums.Role.STUDENT, full_name: 'Zana Zang', class_level: 1, section_id: 401},
      {id: 12, event_id: 191, role_id: Bridgetroll.Enums.Role.STUDENT, full_name: 'Student Person', class_level: 2, section_id: 401},
      {id: 13, event_id: 191, role_id: Bridgetroll.Enums.Role.VOLUNTEER, full_name: 'Bother', section_id: 401, teaching: true, taing: true},
      {id: 14, event_id: 191, role_id: Bridgetroll.Enums.Role.VOLUNTEER, full_name: 'Teacher', section_id: 401, teaching: true, taing: false},
      {id: 15, event_id: 191, role_id: Bridgetroll.Enums.Role.VOLUNTEER, full_name: 'Taer', section_id: 401, teaching: false, taing: true},
      {id: 16, event_id: 191, role_id: Bridgetroll.Enums.Role.VOLUNTEER, full_name: 'Neither', section_id: 401, teaching: false, taing: false}
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

  describe("rendering", function () {
    beforeEach(function () {
      view.render();
    });

    it("renders volunteers with a special letter representing their teaching/ta preferences", function () {
      expect(view.$('[data-id="13"] .bridgetroll-badge').text()).toContain('?');
      expect(view.$('[data-id="14"] .bridgetroll-badge').text()).toContain('T');
      expect(view.$('[data-id="15"] .bridgetroll-badge').text()).toContain('t');
      expect(view.$('[data-id="16"] .bridgetroll-badge').text()).toContain('x');
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
      expect(_.compact(attendees.map(function (attendee) { return attendee.get('section_id') }).sort())).toEqual([11]);
    });
  });

  describe("onEditClick", function () {
    beforeEach(function () {
      view.onEditClick();
    });

    afterEach(function () {
      getFixtures().find('.modal-footer .cancel').click();
    });

    it("presents a modal with editing options", function () {
      expect(getFixtures().find('.modal-body').length).toEqual(1);
    });

    describe("after the modal is saved", function () {
      beforeEach(function () {
        getFixtures().find('.modal-body .section_name').val("Pirate's Bay");
        getFixtures().find('.modal-footer .submit').click();
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

        it("applies changes to the model", function () {
          expect(model.get('name')).toEqual("Pirate's Bay");
        });

        it("closes the modal");
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