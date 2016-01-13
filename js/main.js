function fadeOutAll() {
	$( "#screen-1" ).fadeOut();
	$( "#screen-2" ).fadeOut();
	$( "#screen-3" ).fadeOut();
	$( "#screen-4" ).fadeOut();
	$( "#screen-5" ).fadeOut();
	$( "#screen-6" ).fadeOut();
	$( "#screen-7" ).fadeOut();
	$( "#screen-8" ).fadeOut();
}

fadeOutAll();
$( "#screen-1" ).fadeIn();

window.setTimeout(fadeFromBlack,1000);

function fadeFromBlack() {
	$( "#fade-out" ).fadeOut();
}

function goToPage(page) {
	fadeOutAll();
	console.log(page);
	$( "#screen-" + page ).fadeIn();
}

$( "#importClick" ).click(function() {
	goToPage(4);
});
$( "#editingClick" ).click(function() {
	goToPage(6);
});
$( "#tagsClick" ).click(function() {
	goToPage(4);
});
$( "#bookmarksClick" ).click(function() {
	goToPage(7);
});
$( "#seriesClick" ).click(function() {
	goToPage(4);
});
$( "#writerClick" ).click(function() {
	goToPage(4);
});
$( "#sortClick" ).click(function() {
	goToPage(5);
});
$( "#searchClick" ).click(function() {
	goToPage(5);
});
$( "#viewerClick" ).click(function() {
	goToPage(3);
});

$( "#screen-1" ).click(function() {
	goToPage(2);
});
$( "#screen-3" ).click(function() {
	goToPage(4);
});
$( "#screen-4" ).click(function() {
	goToPage(5);
});
$( "#screen-5" ).click(function() {
	goToPage(6);
});
$( "#screen-6" ).click(function() {
	goToPage(7);
});
$( "#screen-7" ).click(function() {
	goToPage(8);
});
$( "#screen-8" ).click(function() {
	goToPage(1);
});