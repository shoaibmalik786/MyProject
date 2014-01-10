// // $(document).ready(function(){
// // 	$('.subhead').css('z-index','99');
// // 	$('.navbar').css('z-index','100');
// // });
// $(document).scroll(function(){
// 	if($(document).scrollTop() > 0){
// 		$('#bag').css('position','fixed');
// 		$('#painting').css('position','fixed');
// 	}
// 	// if($(document).scrollTop() > 20){
// 	// 		$('.subhead').css('z-index','');
// 	// 		$('.navbar').css('z-index','');
// 	// 	}
// 	// 	if($(document).scrollTop() < 20){
// 	// 		$('.subhead').css('z-index','99');
// 	// 		$('.navbar').css('z-index','100');
// 	// 	}
// 	if($(document).scrollTop() > 900){
// 		$('.home_wants_card').css('position','fixed');
// 		$('.home_wants_card').css('top','180px');
// 		$('.home_wants_card').css('z-index','70');
// 	}
// 	if($(document).scrollTop() < 900){
// 		$('.home_wants_card').css('position','relative');
// 		$('.home_wants_card').css('z-index','70');
// 		$('.home_wants_card').css('top','55px');
// 	}
// 	if($(document).scrollTop() > 1900){
// 		$('.home_wants_card').css('position','absolute');
// 		$('.home_wants_card').css('z-index','70');
// 		$('.home_wants_card').css('top','1050px');
// 		$('#bag').css('position','absolute');
// 		$('#bag').css('top','2198px');
// 	}
// 	if($(document).scrollTop() < 1900){
// 		$('#bag').css('position','fixed');
// 		$('#bag').css('top','306px');
// 	}
// 	if (scrollY>1400) {
// 		$("#bag_box_image").attr('src','http://d3md9h2ro575fr.cloudfront.net/images/home_wants_card_change.png');
// 	};
// 	if (scrollY<1400) {
// 		$("#bag_box_image").attr('src','http://d3md9h2ro575fr.cloudfront.net/images/home_wants_card.png');
// 	};
// 	
// 	if($(document).scrollTop() > 920){
// 		$('.home_user_card').css('position','absolute');
// 		$('.home_user_card').css('z-index','70');
// 		$('#painting').css('position','absolute');
// 		$('#painting').css('top','1072px');
// 		// $("#bag_box_image").attr('src','assets/img/home_wants_card_change.png');
// 	}
// 	if($(document).scrollTop() < 920){
// 		$('.home_user_card').css('position','absolute');
// 		$('.home_user_card').css('z-index','70');
// 		$('.home_user_card').css('top','55px');
// 		$('#painting').css('top','130px');
// 		// $("#bag_box_image").attr('src','assets/img/home_wants_card_change.png');
// 	}
// });
// $(document).ready(function(){
// 	$('.subhead').css('z-index','99');
// 	$('.navbar').css('z-index','100');
// });
// 	var ss = window.innerWidth;
// $(document).ready(function(){
// 	if (ss > 1440){
// 		$('#bag').css('top','420px');
// 	} else if (ss < 1367){
// 		$('#bag').css('top','286px');
// 		$('#painting').css('top','120px');
// 	}	else {
// 		$('#bag').css('top','306px');
// 		}
// });
// $(document).scroll(function(){
// 	if($(document).scrollTop() > 0){
// 		$('#bag').css('position','fixed');
// 		$('#painting').css('position','fixed');
// 	}
// 	if (($(document).scrollTop() > 900) && (ss < 1442)) {
// 		$('.home_wants_card').css('position','fixed');
// 		$('.home_wants_card').css('top','180px');
// 		$('.home_wants_card').css('z-index','70');
// 	}
// 	if (($(document).scrollTop() > 760) && (ss > 1442)) {
// 		$('.home_wants_card').css('position','fixed');
// 		$('.home_wants_card').css('top','320px');
// 		$('.home_wants_card').css('z-index','70');
// 	}
// 	if (($(document).scrollTop() < 900) && (ss < 1442)){
// 		$('.home_wants_card').css('position','relative');
// 		$('.home_wants_card').css('z-index','70');
// 		$('.home_wants_card').css('top','55px');
// 	}
// 	if (($(document).scrollTop() < 740) && (ss > 1442)){
// 		$('.home_wants_card').css('position','relative');
// 		$('.home_wants_card').css('z-index','70');
// 		$('.home_wants_card').css('top','75px');
// 	}
// 	if (($(document).scrollTop() > 1900) && (ss < 1442) && (ss > 1367)) {
// 		$('.home_wants_card').css('position','absolute');
// 		$('.home_wants_card').css('z-index','70');
// 		$('.home_wants_card').css('top','1063px');
// 		$('#bag').css('position','absolute');
// 		$('#bag').css('top','2210px');
// 	}
// 	if (($(document).scrollTop() > 1900) && (ss < 1367)) {
// 		$('.home_wants_card').css('position','absolute');
// 		$('.home_wants_card').css('z-index','70');
// 		$('.home_wants_card').css('top','1063px');
// 		$('#bag').css('position','absolute');
// 		$('#bag').css('top','2190px');
// 	}
// 	if (($(document).scrollTop() > 1750) && (ss > 1442)) {
// 		$('.home_wants_card').css('position','absolute');
// 		$('.home_wants_card').css('z-index','70');
// 		$('.home_wants_card').css('top','1075px');
// 		$('#bag').css('position','absolute');
// 		$('#bag').css('top','2201px');
// 	}
// 	if (($(document).scrollTop() < 1900) && (ss < 1442)) {
// 		$('#bag').css('position','fixed');
// 		$('#bag').css('top','306px');
// 	}
// 	if (($(document).scrollTop() < 1900) && (ss < 1367)) {
// 		$('#bag').css('position','fixed');
// 		$('#bag').css('top','286px');
// 		$('#painting').css('top','120px');
// 	}
// 	if (($(document).scrollTop() < 1750) && (ss > 1442)) {
// 		$('#bag').css('position','fixed');
// 		$('#bag').css('top','420px');
// 	}
// 	if ((scrollY>1400) && (ss < 1442)) {
// 		$("#bag_box_image").attr('src','http://d3md9h2ro575fr.cloudfront.net/images/home_wants_card_change.png');
// 	};
// 	if ((scrollY<1400) && (ss < 1442)) {
// 		$("#bag_box_image").attr('src','http://d3md9h2ro575fr.cloudfront.net/images/home_wants_card.png');
// 	};
// 	if ((scrollY>1200) && (ss > 1442)) {
// 		$("#bag_box_image").attr('src','http://d3md9h2ro575fr.cloudfront.net/images/home_wants_card_change.png');
// 	};
// 	if ((scrollY<1200) && (ss > 1442)) {
// 		$("#bag_box_image").attr('src','http://d3md9h2ro575fr.cloudfront.net/images/home_wants_card.png');
// 	};
	
// 	if (($(document).scrollTop() > 945) && (ss < 1442) && (ss > 1367)){
// 		$('.home_user_card').css('position','absolute');
// 		$('.home_user_card').css('z-index','70');
// 		$('#painting').css('position','absolute');
// 		$('#painting').css('top','1076px');
// 		// $("#bag_box_image").attr('src','assets/img/home_wants_card_change.png');
// 	}
// 	if (($(document).scrollTop() > 945) && (ss < 1367)){
// 		$('.home_user_card').css('position','absolute');
// 		$('.home_user_card').css('z-index','70');
// 		$('#painting').css('position','absolute');
// 		$('#painting').css('top','1065px');
// 		// $("#bag_box_image").attr('src','assets/img/home_wants_card_change.png');
// 	}
// 	if (($(document).scrollTop() < 945) && (ss < 1442) && (ss > 1367)){
// 		$('.home_user_card').css('position','absolute');
// 		$('.home_user_card').css('z-index','70');
// 		$('.home_user_card').css('top','55px');
// 		$('#painting').css('top','130px');
// 		// $("#bag_box_image").attr('src','assets/img/home_wants_card_change.png');
// 	}
// 	if (($(document).scrollTop() < 920) && (ss < 1367)){
// 		$('.home_user_card').css('position','absolute');
// 		$('.home_user_card').css('z-index','70');
// 		$('.home_user_card').css('top','55px');
// 		$('#painting').css('top','120px');
// 		// $("#bag_box_image").attr('src','assets/img/home_wants_card_change.png');
// 	}
// 	if (($(document).scrollTop() > 945) && (ss > 1442)){
// 		$('.home_user_card').css('position','absolute');
// 		$('.home_user_card').css('z-index','70');
// 		$('#painting').css('position','absolute');
// 		$('#painting').css('top','1079px');
// 		// $("#bag_box_image").attr('src','assets/img/home_wants_card_change.png');
// 	}
// 	if (($(document).scrollTop() < 945) && (ss > 1442)){
// 		$('.home_user_card').css('position','absolute');
// 		$('.home_user_card').css('z-index','70');
// 		$('#painting').css('position','fixed');
// 		$('#painting').css('top','130px');
// 		// $("#bag_box_image").attr('src','assets/img/home_wants_card_change.png');
// 	}
// });

