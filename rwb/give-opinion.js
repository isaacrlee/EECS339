$(document).ready(function() {
	navigator.geolocation.getCurrentPosition(Start);
});

Start = function (location) {
	var lat = location.coords.latitude;
	var lng = location.coords.longitude;
	var acc = location.coords.accuracy;
	$("input[name='lat']").attr('value', lat);
	$("input[name='lng']").attr('value', lng);
}
