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

  it("renders each of the students from the original collection", function () {
    sectionOrganizer.render();
    expect(sectionOrganizer.$el.text()).toContain('Lana Lang');
    expect(sectionOrganizer.$el.text()).toContain('Sue Storm');
    expect(sectionOrganizer.$el.text()).toContain('Ted Moesby');
  });

  describe("#addSection", function () {
    it("adds a new section as a subview", function () {
      sectionOrganizer.render();
      expect(sectionOrganizer.$('.bridgetroll-section').length).toEqual(0);

      sectionOrganizer.addSection();
      expect(sectionOrganizer.$('.bridgetroll-section').length).toEqual(1);

      sectionOrganizer.addSection();
      expect(sectionOrganizer.$('.bridgetroll-section').length).toEqual(2);
    });
  });
});