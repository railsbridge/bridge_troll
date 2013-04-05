// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery.ui.datepicker

//= require select2
//= require modernizr
//= require_tree .
//= require jquery_nested_form
//= require dataTables/jquery.dataTables
//= require dataTables/jquery.dataTables.bootstrap

$(document).ready(function () {
  $('.datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "iDisplayLength": 50
  });

  if ($(window).height() < $('html').height()) {
    $('footer').show();
  }
});