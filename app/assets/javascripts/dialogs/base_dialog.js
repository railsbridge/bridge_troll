Bridgetroll.Dialogs.Base = (function () {
  return Bridgetroll.Views.Base.extend({
    showModally: function () {
      this.render();
      $(Bridgetroll.modalContainerSelector).append(this.el);
      $(this.el).modal();

      this.$el.on('shown', function () {
        $(this).find('.btn').focus();
      });

      $(this.el).on('hidden', _.bind(function () {
        this.destroy();
      }, this));
    }
  });
})();