window.whenReady(function () {
  if ($(window).height() < $('html').height()) {
    $('footer').show();
  }
});
