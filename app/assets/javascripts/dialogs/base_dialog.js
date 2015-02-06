Bridgetroll.Dialogs.Base = (function () {
  return Bridgetroll.Views.Base.extend({
    className: function () {
      if (Bridgetroll.railsEnv === 'test') {
        return 'modal';
      } else {
        return 'modal fade';
      }
    },
    showModally: function () {
      this.render();
      $(Bridgetroll.modalContainerSelector).append(this.el);
      $(this.el).modal();

      this.$el.on('modal.bs.shown', function () {
        $(this).find('.btn').focus();
        $(this).find('[autofocus]').focus();
      });

      $(this.el).on('hidden', _.bind(function () {
        this.destroy();
      }, this));
    }
  });
})();