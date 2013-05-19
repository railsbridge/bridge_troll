describe("SectionOrganizer", function() {
  var sectionOrganizer;
  var students;
  beforeEach(function() {
    students = new Bridgetroll.Collections.Student([
      {name: 'Lana Lang'},
      {name: 'Sue Storm'},
      {name: 'Ted Moesby'}
    ]);
    sectionOrganizer = new Bridgetroll.Views.SectionOrganizer({students: students});
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