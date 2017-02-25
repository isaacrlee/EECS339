$(document).ready(function() {
	navigator.geolocation.getCurrentPosition(Start);
});

Start = function (location) {
	var lat = location.coords.latitude;
	var long = location.coords.longitude;
	var acc = location.coords.accuracy;
	console.log(lat);
	$.get("rwb.pl",
	{
		act:	"give-opinion-data",
		lat_cen:	lat,
		long_cen:	long,
		});
}
