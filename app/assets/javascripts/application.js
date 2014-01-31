// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery.ui.datepicker
//= require twitter/bootstrap/modal
//= require twitter/bootstrap/transition
//= require twitter/bootstrap/tooltip
//= require twitter/bootstrap/popover
//= require select2
//= require handlebars.runtime
//= require underscore
//= require gmaps/google
//= require backbone
//= require backbone-super
//= require jquery.event.drag
//= require jquery.event.drop
//= require bridgetroll
//= require_tree ../templates
//= require_tree ./enums
//= require_tree ./models
//= require_tree ./collections
//= require ./views/base_view
//= require_tree ./views
//= require ./dialogs/base_dialog
//= require_tree ./dialogs
//= require_tree .
//= require jquery_nested_form
//= require dataTables/jquery.dataTables
//= require dataTables/jquery.dataTables.bootstrap

$(document).ready(function () {
  var tableNeedsPagination = $('.datatable-sorted tbody tr').length > 10 ? true : false;
  $.extend( $.fn.dataTable.defaults, {
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "iDisplayLength": 50
  });

  $('.datatable').dataTable();

  $('.datatable-sorted').dataTable({
    "bPaginate": tableNeedsPagination,
    "aaSorting": [[ 1, "desc" ]],
    "aoColumnDefs": [
      {'aTargets': ['date'], "sType": "date"}
    ]
  });

  $('.datatable-checkins').dataTable({
    "bPaginate": false,
    "aaSorting": [[ 0, "asc" ]],
    "aoColumnDefs": [
      {'aTargets': ['checkins-name']},
      {'aTargets': ['checkins-role']},
      {'aTargets': ['checkins-action'], bSortable: false}
    ]
  });

  if ($(window).height() < $('html').height()) {
    $('footer').show();
  }
});
