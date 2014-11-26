describe("Bridgetroll.Views.Section", function () {
  var view, model, attendees, vols, Role;
  beforeEach(function () {
    vols = {};
    vols['bother']  = Factories.volunteer({event_id: 191, section_id: 401, teaching: true, taing: true});
    vols['teacher'] = Factories.volunteer({event_id: 191, section_id: 401, teaching: true, taing: false});
    vols['taer']    = Factories.volunteer({event_id: 191, section_id: 401, teaching: false, taing: true});
    vols['neither'] = Factories.volunteer({event_id: 191, section_id: 401, teaching: false, taing: false});

    attendees = new Bridgetroll.Collections.Attendee([
      Factories.student({event_id: 191, full_name: 'Othersection Rand', section_id: 11}),
      Factories.student({event_id: 191, full_name: 'Lana Lang', class_level: 1, section_id: 401}),
      Factories.student({event_id: 191, full_name: 'Zana Zang', class_level: 1, section_id: 401}),
      Factories.student({event_id: 191, full_name: 'Student Person', class_level: 2, section_id: 401}),
      vols['bother'], vols['teacher'], vols['taer'], vols['neither']
    ]);
    model = new Bridgetroll.Models.Section({
      class_level: 1,
      id: 401,
      event_id: 191,
      name: "Wizard's Throne"
    });
    view = new Bridgetroll.Views.Section({
      levels: _.map([1, 2, 3, 4, 5], function (n) { return {color: 'color-' + n, index: n}}),
      section: model,
      attendees: attendees,
      selectedSession: new Bridgetroll.Models.Section({id: 2, name: 'Cool Section'}),
      displayProperties: new Backbone.Model()
    });
  });

  describe("rendering", function () {
    beforeEach(function () {
      view.render();
    });

    it("renders volunteers with a special letter representing their teaching/ta preferences", function () {
      expect(view.$('[data-id="' + vols['bother'].id + '"] .bridgetroll-badge')).toContainText('?');
      expect(view.$('[data-id="' + vols['teacher'].id + '"] .bridgetroll-badge')).toContainText('T');
      expect(view.$('[data-id="' + vols['taer'].id + '"] .bridgetroll-badge')).toContainText('t');
      expect(view.$('[data-id="' + vols['neither'].id + '"] .bridgetroll-badge')).toContainText('x');
    });

  });

  describe("#attachPoint", function () {
    describe("when the section is for unassigned students", function () {
      beforeEach(function () {
        view.section.set('class_level', null);
      });

      it("returns level0", function () {
        expect(view.attachPoint()).toEqual('.bridgetroll-section-level.level0')
      });
    });

    describe("when the section is a real section", function () {
      it("returns the class level of the section", function () {
        expect(view.attachPoint()).toEqual('.bridgetroll-section-level.level1')
      });
    });
  });

  describe("onDestroyClick", function () {
    beforeEach(function () {
      spyOn(window, 'confirm').and.returnValue(true);
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
        getFixtures().find('.modal-body .class_level[value="4"]').prop('checked', true);
        getFixtures().find('.modal-footer .submit').click();
      });

      it("makes a request to update the name with the prompted value", function () {
        var request = this.server.requestFor('/events/191/sections/401');
        expect(request).not.toBeUndefined();
        expect(JSON.parse(request.requestBody).section.name).toEqual("Pirate's Bay");
        expect(JSON.parse(request.requestBody).section.class_level).toEqual("4");
      });

      describe("when the request completes", function () {
        beforeEach(function () {
          this.server.completeRequest('/events/191/sections/401', {
            id: 401,
            event_id: 191,
            class_level: 4,
            name: "Pirate's Bay"
          });
        });

        it("applies changes to the model", function () {
          expect(model.get('name')).toEqual("Pirate's Bay");
        });
      });
    });
  });

  describe("#moveAttendeeToSection", function () {
    var movingStudent;
    beforeEach(function () {
      movingStudent = attendees.at(1);
      view.moveAttendeeToSection(movingStudent.id);
    });

    it("makes a request to save the new section_id", function () {
      var request = this.server.requestFor('/events/191/attendees/' + movingStudent.id);
      expect(request).not.toBeUndefined();
      expect(JSON.parse(request.requestBody).attendee.section_id).toEqual(401);
    });

    describe("when the request completes successfully", function () {
      beforeEach(function () {
        spyOn(view, 'trigger');
        this.server.completeRequest('/events/191/attendees/' + movingStudent.id, {
          id: movingStudent.id,
          event_id: 191,
          section_id: 401,
          full_name: movingStudent.get('full_name')
        });
      });

      it("triggers a section:changed event", function () {
        expect(view.trigger).toHaveBeenCalledWith('section:changed');
      });
    });
  });
});