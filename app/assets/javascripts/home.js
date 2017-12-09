var hidable = [".menu ul li"];
var menu_elements = [".menu"];

$(function(){
	$(window).resize(function() {
		if ($(window).width()<650){
			hidable.forEach(function (el) {
				$(el).hide();
			});
			menu_elements.forEach(function (el) {
				$(el).css("padding", "0px");
			});
		}
		else {
			hidable.forEach(function (el) {
				$(el).show();
			});
			menu_elements.forEach(function (el) {
				$(el).css("padding", "30px");
			});
		}
	});
	$(".menu span").click(function(){
		$(".menu ul li").toggle(200);
	});
});
