$( "#screen-2" ).fadeOut();
$( "#screen-3" ).fadeOut();
$( "#screen-4" ).fadeOut();
$( "#screen-5" ).fadeOut();
$( "#screen-6" ).fadeOut();
$( "#screen-7" ).fadeOut();
$( "#screen-8" ).fadeOut();

window.setTimeout(fadeFromBlack,1000);

function fadeFromBlack() {
	$( "#fade-out" ).fadeOut();
}

$( "#screen-1" ).click(function() {
  $( "#screen-1" ).fadeOut();
  $( "#screen-2" ).fadeIn();
});
$( "#screen-2" ).click(function() {
  $( "#screen-2" ).fadeOut();
  $( "#screen-3" ).fadeIn();
});
$( "#screen-3" ).click(function() {
  $( "#screen-3" ).fadeOut();
  $( "#screen-4" ).fadeIn();
});
$( "#screen-4" ).click(function() {
  $( "#screen-4" ).fadeOut();
  $( "#screen-5" ).fadeIn();
});
$( "#screen-5" ).click(function() {
  $( "#screen-5" ).fadeOut();
  $( "#screen-6" ).fadeIn();
});
$( "#screen-6" ).click(function() {
  $( "#screen-6" ).fadeOut();
  $( "#screen-7" ).fadeIn();
});
$( "#screen-7" ).click(function() {
  $( "#screen-7" ).fadeOut();
  $( "#screen-8" ).fadeIn();
});
$( "#screen-8" ).click(function() {
  $( "#screen-8" ).fadeOut();
  $( "#screen-1" ).fadeIn();
});