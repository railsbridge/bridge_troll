Bridgetroll.Views.AutoArrangeChoices = (function () {
  function checkedIn (collection) {
    return collection.filter(function(a) { return a.get('checkins_count') > 0 });
  }

  return Bridgetroll.Dialogs.Base.extend({
    className: function () {
      return this._super('className', arguments) + ' auto-arrange-choices';
    },
    template: 'section_organizer/auto_arrange_choices',

    events: {
      "change [name=auto-arrange-choice]": 'onChoiceChange'
    },

    initialize: function (params) {
      this.sessions = params.sessions;
      this.volunteers = params.volunteers;
      this.students = params.students;

      this.checkedInCounts = {
        indiscriminate: {
          volunteers: this.volunteers.length,
          students: this.students.length
        },
        any: {
          volunteers: checkedIn(this.volunteers).length,
          students: checkedIn(this.students).length
        }
      };
    },

    context: function () {
      var sessionsJson = this.sessions.map(_.bind(function (session) {
        var json = session.toJSON();
        json.checkedInStudents = session.checkedInStudents(this.students);
        json.checkedInVolunteers = session.checkedInVolunteers(this.volunteers);
        return json;
      }, this));
      return {
        sessions: sessionsJson,
        checkedInCounts: this.checkedInCounts
      }
    },

    onChoiceChange: function () {
      var choice = this.$('[name="auto-arrange-choice"]:checked').val();

      var parser = document.createElement('a');
      parser.href = this.$('.btn').attr('href');

      this.$('.btn').attr('href', parser.pathname + '?checked_in_to=' + choice);
    }
  });
})();
