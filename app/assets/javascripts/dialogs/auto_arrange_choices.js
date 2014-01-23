Bridgetroll.Views.AutoArrangeChoices = (function () {
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
      this.checkedInCounts = params.checkedInCounts;
    },

    context: function () {
      return {
        sessions: this.sessions,
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
