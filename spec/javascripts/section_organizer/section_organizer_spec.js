describe("SectionOrganizer", function () {
  var sectionOrganizer, attendees, sections;
  beforeEach(function () {
    attendees = new Bridgetroll.Collections.Attendee([
      {id: 1, section_id: null, class_level: 0, role_id: Bridgetroll.Enums.Role.STUDENT, full_name: 'Lana Lang'},
      {id: 2, section_id: null, class_level: 0, role_id: Bridgetroll.Enums.Role.STUDENT, full_name: 'Sue Storm'},
      {id: 3, section_id: null, class_level: 0, role_id: Bridgetroll.Enums.Role.STUDENT, full_name: 'Ted Moesby'},
      {id: 4, section_id: null, class_level: 0, role_id: Bridgetroll.Enums.Role.VOLUNTEER, full_name: 'Paul Graham'},
      {id: 5, section_id: null, class_level: 0, role_id: Bridgetroll.Enums.Role.VOLUNTEER, full_name: 'Grace Hopper'}
    ]);
    sections = new Bridgetroll.Collections.Section([
      {
        event_id: 191,
        id: 1234,
        name: 'Classroom #9'
      },
      {
        event_id: 191,
        id: 5678,
        name: 'Spaceship #491'
      }
    ]);
    sectionOrganizer = new Bridgetroll.Views.SectionOrganizer({
      event_id: 191,
      sections: sections,
      attendees: attendees
    });
  });

  describe("after rendering", function () {
    beforeEach(function () {
      sectionOrganizer.render();
    });

    it("contains each of the students from the original collection", function () {
      expect(sectionOrganizer.$el.text()).toContain('Lana Lang');
      expect(sectionOrganizer.$el.text()).toContain('Sue Storm');
      expect(sectionOrganizer.$el.text()).toContain('Ted Moesby');
    });

    it("contains each of the volunteers from the original collection", function () {
      expect(sectionOrganizer.$el.text()).toContain('Paul Graham');
      expect(sectionOrganizer.$el.text()).toContain('Grace Hopper');
    });

    it("contains each of the sections from the original collection", function () {
      expect(sectionOrganizer.$el.text()).toContain('Classroom #9');
      expect(sectionOrganizer.$el.text()).toContain('Spaceship #491');
    });
  });

  describe("#onAddSectionClick", function () {
    var sectionCount;
    beforeEach(function () {
      sectionOrganizer.render();
      sectionCount = sectionOrganizer.$('.bridgetroll-section').length;
      sectionOrganizer.onAddSectionClick();
    });

    it("posts to the server to create a new section", function () {
      expect(this.server.requestFor('/events/191/sections')).not.toBeUndefined();
    });

    it("does not add a subview", function () {
      expect(sectionOrganizer.$('.bridgetroll-section').length).toEqual(sectionCount);
    });

    describe("when the request has complete", function () {
      beforeEach(function () {
        this.server.completeRequest('/events/191/sections', {
          id: 9102,
          name: 'New Section'
        });
      });

      it("adds a new section as a subview", function () {
        expect(sectionOrganizer.$('.bridgetroll-section').length).toEqual(sectionCount + 1);
      });
    });
  });
});