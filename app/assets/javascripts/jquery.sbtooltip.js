/*
 * Speech-Bubble Tooltip - jQuery
 * --------------------------------------------------------------------
 * by Jamy Golden, jamyg88@gmail.com, http://css-plus.com/
 * --------------------------------------------------------------------
 */
jQuery.fn.sbTooltip = function() {
	return this.each(function(){
		jQuery(this).attr({sbtooltip: jQuery(this).attr("title")}).removeAttr("title");
	});
};
