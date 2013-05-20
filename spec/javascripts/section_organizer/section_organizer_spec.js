describe("SectionOrganizer", function() {
  var sectionOrganizer, students, volunteers;
  beforeEach(function() {
    students = new Bridgetroll.Collections.Student([
      {name: 'Lana Lang'},
      {name: 'Sue Storm'},
      {name: 'Ted Moesby'}
    ]);
    volunteers = new Bridgetroll.Collections.Volunteer([
      {name: 'Paul Graham'},
      {name: 'Grace Hopper'}
    ]);
    sectionOrganizer = new Bridgetroll.Views.SectionOrganizer({
      students: students,
      volunteers: volunteers
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