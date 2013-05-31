describe("SectionOrganizer", function() {
  var sectionOrganizer, attendees;
  beforeEach(function() {
    attendees = new Bridgetroll.Collections.Attendee([
      {role_id: Bridgetroll.Enums.Role.STUDENT, name: 'Lana Lang'},
      {role_id: Bridgetroll.Enums.Role.STUDENT, name: 'Sue Storm'},
      {role_id: Bridgetroll.Enums.Role.STUDENT, name: 'Ted Moesby'},
      {role_id: Bridgetroll.Enums.Role.VOLUNTEER, name: 'Paul Graham'},
      {role_id: Bridgetroll.Enums.Role.VOLUNTEER, name: 'Grace Hopper'}
    ]);
    sectionOrganizer = new Bridgetroll.Views.SectionOrganizer({
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

    describe("add section button", function () {
      it("should invoke #addSection", function () {
        spyOn(sectionOrganizer, 'addSection');
        sectionOrganizer.$('.add-section').click();
        sectionOrganizer.$('.add-section').click(); // TODO: not this
        expect(sectionOrganizer.addSection).toHaveBeenCalled();
      });
    });
  });

  describe("#addSection", function () {
    it("adds a new section as a subview", function () {
      sectionOrganizer.render();

      var sectionCount = sectionOrganizer.$('.bridgetroll-section').length;
      sectionOrganizer.addSection();
      expect(sectionOrganizer.$('.bridgetroll-section').length).toEqual(sectionCount + 1);
    });
  });
});