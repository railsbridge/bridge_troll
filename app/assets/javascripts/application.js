//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require_self
//= require_tree .


var bridge_troll = (function(bridge_troll, $) {
  $(function(){
    $(".date_picker").datepicker();
  });

  return bridge_troll;
})(bridge_troll || {}, jQuery);
