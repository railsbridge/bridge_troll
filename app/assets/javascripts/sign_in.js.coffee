$ ->
	$('#sign_in').hover(
		-> $(this).children("ul").show(),
		-> $(this).children("ul").hide())