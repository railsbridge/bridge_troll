describe("Bridgetroll.Views.SectionOrganizer", function () {
  var sectionOrganizer, attendees, sections;
  beforeEach(function () {
    attendees = new Bridgetroll.Collections.Attendee([
      Factories.student({section_id: null, class_level: 0, full_name: 'Lana Lang'}),
      Factories.student({section_id: null, class_level: 0, full_name: 'Sue Storm'}),
      Factories.student({section_id: null, class_level: 0, full_name: 'Ted Moesby'}),
      Factories.student({section_id: null, class_level: 0, full_name: 'Apricot Jam'}),
      Factories.student({section_id: null, class_level: 0, full_name: 'Grace Hopper'}),
    ]);
  });

  describe("when there are existing sections", function () {
    beforeEach(function () {
      sections = new Bridgetroll.Collections.Section([
        {
          class_level: 2,
          event_id: 191,
          id: 1234,
          name: 'Classroom #9'
        },
        {
          class_level: 4,
          event_id: 191,
          id: 5678,
          name: 'Spaceship #491'
        }
      ]);
      sessions = new Bridgetroll.Collections.Session([{
        id: 1,
        name: 'Workshop'
      }]);
      sectionOrganizer = new Bridgetroll.Views.SectionOrganizer({
        event_id: 191,
        sections: sections,
        attendees: attendees,
        sessions: sessions
      });
    });

    describe("after rendering", function () {
      beforeEach(function () {
        sectionOrganizer.render();
      });

      it("contains each of the students from the original collection", function () {
        expect(sectionOrganizer.$el).toContainText('Lana Lang');
        expect(sectionOrganizer.$el).toContainText('Sue Storm');
        expect(sectionOrganizer.$el).toContainText('Ted Moesby');
      });

      it("contains each of the volunteers from the original collection", function () {
        expect(sectionOrganizer.$el).toContainText('Apricot Jam');
        expect(sectionOrganizer.$el).toContainText('Grace Hopper');
      });

      it("contains each of the sections from the original collection", function () {
        expect(sectionOrganizer.$el).toContainText('Classroom #9');
        expect(sectionOrganizer.$el).toContainText('Spaceship #491');
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
            class_level: null,
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
});