// Código basado en:
// https://github.com/garrettgman
// https://github.com/rstudio/shiny-examples/blob/master/063-superzip-example/styles.css


$(document).on("click", ".go-map", function(e) {
  e.preventDefault();
  $el = $(this);
  var lat = $el.data("lat");
  var long = $el.data("long");
  var refugio = $el.data("refugio");
  $($("#nav a")[0]).tab("show");
  Shiny.onInputChange("goto", {
    lat: lat,
    lng: long,
    ref: refugio,
    nonce: Math.random()
  });
});