// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

var recorderManager;
var recorder;
var player;
var recImgData;
var isRecorderInit = false;
var isMarginLeft = false;
var rCount = 0;
var isLoadingNextPage = false;
var pageSize=20;
var VIDEO_HEIGHT = 240;
var VIDEO_WIDTH = 320;
var canSubmitCanNext = true;

// Un-comment either of the following to set automatic logging and exception handling.
// See the exceptionHandler() method below.
// TB.setLogLevel(TB.DEBUG);
// TB.addEventListener('exception', exceptionHandler);

function init() {
	recorderManager = TB.initRecorderManager(API_KEY);
	createRecorder();
	isRecorderInit = true;
}

function createRecorder() {
	var recDiv = document.createElement('div');
	recDiv.setAttribute('id', 'recorderElement');
	document.getElementById('recorderContainer').appendChild(recDiv);
	recorder = recorderManager.displayRecorder(TOKEN, recDiv.id);
	recorder.addEventListener('recordingStarted', recStartedHandler);
	recorder.addEventListener('archiveSaved', archiveSavedHandler);
}

function getImg(imgData) {
	var img = document.createElement('img');
	img.setAttribute('src', 'data:image/png;base64,' + imgData);
	return img;
}

function loadArchiveInPlayer(archiveId) {
	if (!player) {
		playerDiv = document.createElement('div');
		playerDiv.setAttribute('id', 'playerElement');
		document.getElementById('playerContainer').appendChild(playerDiv);
		player = recorderManager.displayPlayer(archiveId, TOKEN, playerDiv.id);
	} else {
		player.loadArchive(archiveId);
	}
}

//--------------------------------------
//  OPENTOK EVENT HANDLERS
//--------------------------------------

function recStartedHandler(event) {
	recImgData = recorder.getImgData();
}

function archiveSavedHandler(event) {
	document.getElementById('recorder_div').style.display = 'none';
	document.getElementById('player_div').style.display = 'block';
	var spanArchive = document.createElement('div');
	spanArchive.setAttribute('style', 'width: 80px; height: 80px; margin-left: ' + (isMarginLeft ? 30 : 0) + 'px; margin-top: 3px; text-align: center; float: left');

	var archId = event.archives[0].archiveId;

	var aLink = document.createElement('a');
	aLink.setAttribute('href', "javascript:loadArchiveInPlayer(\'" + archId + "\');");
	var recImg = getImg(recImgData);
	recImg.setAttribute('style', 'width:80px; height:60px;');
	aLink.appendChild(recImg);

	spanArchive.appendChild(aLink);

	var rInput = document.createElement('input');
	rInput.setAttribute('type', 'radio');
	rInput.setAttribute('name', 'archive_id');
	rInput.setAttribute('value', archId);
	rInput.setAttribute('checked', 'checked');

	spanArchive.appendChild(rInput);

	document.getElementById('archiveList').appendChild(spanArchive);
	isMarginLeft = !isMarginLeft;

	loadArchiveInPlayer(archId);
}

function archiveLoadedHandler(event) {
	archive = event.archives[0];
	archive.startPlayback();
}

/*
If you un-comment the call to TB.addEventListener('exception', exceptionHandler) above, OpenTok calls the
exceptionHandler() method when exception events occur. You can modify this method to further process exception events.
If you un-comment the call to TB.setLogLevel(), above, OpenTok automatically displays exception event messages.
*/
function exceptionHandler(event) {
	alert('Exception: ' + event.code + '::' + event.message);
}

function playVideo(playerId, file, autoPlay, carouselId){
	flowplayer(playerId, "/assets/flowplayer-3.2.11.swf", 
		{clip: 
			{url: file, autoPlay: autoPlay, autoBuffering: true, scaling: "fit",
				onStart: function(){if(carouselId)isStopCarousal[carouselId] = true;},
				onResume: function(){if(carouselId)isStopCarousal[carouselId] = true;},
				onPause: function(){if(carouselId)isStopCarousal[carouselId] = false;},
				onFinish: function(){
					if(carouselId)isStopCarousal[carouselId] = false;
					if(isHoverVideo)setTimeout(function() {hideVideoModal();}, 500);
				}
			},
			bgcolor: "#000000",
			canvas: {
				backgroundColor: 'transparent',
				backgroundGradient: 'none'
			}
		}
	);
}

function videoAsImage(playerId, file){
	flowplayer(playerId, "/assets/flowplayer-3.2.11.swf", 
		{
			clip: {
				url: file,
				autoPlay: false, 
				autoBuffering: true, 
				scaling: "fit",
    			onBeforeResume: function(){
        			alert("player resume.");
    			},
			},
			plugins: {
			    controls: null
			},
			bgcolor: "#000000",
			canvas: {
				backgroundColor: 'transparent',
				backgroundGradient: 'none'
			}			
		}
	);
}

function videoAsRedirect(playerId, file,redirect,KMdata,GAdata){
	flowplayer(playerId, "/assets/flowplayer-3.2.11.swf", 
		{
			clip: {
				url: file,
				autoPlay: false, 
				autoBuffering: true, 
				scaling: "fit",
    			onBeforeResume: function(){
    				// if ((typeof(KMdata) != 'undefined') && (KMdata.length > 0))
    				// {	_kmq.push(KMdata); }
    				// if ((typeof(GAdata) != 'undefined') && (GAdata.length > 0))
    				// {	_gaq.push(GAdata); }
    				if ((typeof(redirect) != 'undefined') && (redirect.length > 0))
        			{ 
       					window.location = redirect; 
        			}
    			},
    			onResume: function(){
    				$f(playerId).pause();
    			} 
			},
			plugins: {
			    controls: null
			},
			bgcolor: "#000000",
			canvas: {
				backgroundColor: 'transparent',
				backgroundGradient: 'none'
			}			
		}
	);
}

function hideVideoModal(){
	// hideModal('hover_video_div', true);
	$('#hover_video_div').modal('hide');
	isHoverVideo = false;
}

var usertitleMouseover = false;
var usermodalMouseover = false;
var isHoveUserProfile = false;
function hoverUserProfile(hoverItem, imgUrl, name, location, profile_complete, pn, fb,fb_frnds,fb_mutual_conn, goods, services, interests, wish, a_tag, show_mc){
	// if(isHoverVideo || isHoveUserProfile) return;
	// if (usertitleMouseover || usermodalMouseover) return;
	var modalId = "";
	if(profile_complete){
		$('#upImage').attr('src', imgUrl);
		$('#upName').text(name);
		$('#upLoc').text(location);
		// $('#upAboutMe').html(aboutMe);
		// $('#usr_rev_box_s').hide();
		if (!pn) 
			$('#phone_verified_div').hide();
		else 
			$('#phone_verified_div').show();
		if (!fb) 
			$('#facebook_connect').hide();
		else 
			{
				$('#facebook_connect').show();
				$('#fb_frnds').text(fb_frnds + ' Friends');
				if (show_mc) 
					$('#fb_mutual_conn').text(fb_mutual_conn + ' Mutual Connections');
				else
					$('#fb_mutual_conn').text("");
			}
		$('#user_tradeyas_count').text("");
		$('#user_tradeyas_count').append(a_tag);
		$('#user_wish').text(wish);
		$('#user_goods').text(goods);
		$('#user_services').text(services);
		$('#user_interests').text(interests);
		modalId = 'usr_rev_box';
	}else{
		$('#upImageS').attr('src', imgUrl);
		$('#upNameS').text(name);
		$('#upLocS').text(location);
		// $('#upAboutMeS').text(aboutMe);
		// $('#usr_rev_box').hide();
		if (!pn) 
			$('#phone_verified_div_s').hide();
		else 
			$('#phone_verified_div_s').show();
		if (!fb) 
			$('#facebook_connect_s').hide();
		else 
			{
				$('#facebook_connect_s').show();
				$('#fb_frnds_s').text(fb_frnds + ' Friends');
				if (show_mc)
					$('#fb_mutual_conn_s').text(fb_mutual_conn + ' Mutual Connections');
				else
					$('#fb_mutual_conn_s').text("");
			}
		$('#user_tradeyas_count_s').text("");
		$('#user_tradeyas_count_s').append(a_tag);
		modalId = 'usr_rev_box_s';
	 }
	// showModal(modalId, true);
	$('#'+ modalId).modal('show');
	isHoveUserProfile = true;
	setTimeout(function() {custom_scroll('user_pro_detail_id');}, 3000);
	// if($(hoverItem).hasClass('userprofilelink')){
	// 	setTimeout(function() {
	// 		if(isOverlap(hoverItem, modalId)){
	// 			usermodalMouseover = true;
	// 		}
	// 	}, 200);
	// 	usertitleMouseover = true;
	// }
}

// $(function(){
// 	$(".userprofilelink").mouseleave(function(){
// 		if(usertitleMouseover){
// 			usertitleMouseover = false;
// 			setTimeout(function() {hideUserProfileModal();}, 100);
// 		}
// 	});
// 	$("#usr_rev_box, #usr_rev_box_s").mouseenter(function(){
// 		usermodalMouseover = true;
// 	}).mouseleave(function(){
// 		if(usermodalMouseover){
// 			usermodalMouseover = false;
// 			hideUserProfileModal();
// 		}
// 	});
// });

// function isOverlap(d1, d2){
// 	var d1_left = $(d1).offset().left;
// 	var d1_top = $(d1).offset().top;
// 	var d1_width = $(d1).width();
// 	var d1_height = $(d1).height();
// 	var d1_right = d1_left + d1_width;
// 	var d1_bottom = d1_top + d1_height;
// 	
// 	var d2_left = $('#' + d2).css('left');
// 	var d2_top = $('#' + d2).css('top');
// 	var d2_width = $('#' + d2).width();
// 	var d2_height = $('#' + d2).height();
// 	var d2_right = d2_left + d2_width;
// 	var d2_bottom = d2_top + d2_height;
// 	if(((d1_left >= d2_left && d1_right <= d2_right) || (d2_left >= d1_left && d2_right <= d1_right)) && ((d1_top >= d2_top && d1_bottom <= d2_bottom) || (d2_top >= d1_top && d2_bottom <= d1_bottom))){
// 		return true;
// 	}else{
// 		return false;
// 	}
// }

function hideUserProfileModal(){
	// if (!usertitleMouseover && !usermodalMouseover){
		$('#usr_rev_box_s').modal('hide');
		$('#usr_rev_box').modal('hide');
		// hideModal('usr_rev_box_s', true); 
		// hideModal('usr_rev_box', true);
	// }
	isHoveUserProfile = false;
	return false;
}

function clickImage(imgUrl, isAutoWidth, isItem){
	$('#hoverImage').addClass('modal-item')
	if ((typeof(isItem) != 'undefined') && (isItem==true))
		$('#hoverImage').addClass('modal-item')
		// $('#hoverImage').attr('src', imgUrl);
	if(isAutoWidth){
		$('#hoverImage').css('width', 'auto');
		$('#hoverImage').css('height', '300px');
	}else{
		$('#hoverImage').css('width', '405px');
		$('#hoverImage').css('height', 'auto');
	}
	// showModal('hover_image_div', true);
	$('#hover_image_div').modal('show'); 
}
function clickAllImage(imgUrl){
    $("#large_image img").attr('src', imgUrl);
    $(this).parent().addClass('image_selected');
    $("#hoverImage").attr('src', imgUrl);
    // alert("changed");
}

function clickHoverImage(imgUrl){
    $("#hoverImage").attr('src', imgUrl);
    // alert("hover");
}

function clickVideo(videoUrl){
	playVideo('hoverVideo', videoUrl, false);
	$('#hover_video_div').modal('show');
	// showModal('hover_video_div', true);
}
function hoverImg(imgUrl, isAutoWidth, isItem){
	if(isHoverVideo || isHoveUserProfile) return;
	$('#hoverImage').removeClass('modal-item')
	if ((typeof(isItem) != 'undefined') && (isItem==true))
		$('#hoverImage').addClass('modal-item')
	$('#hoverImage').attr('src', imgUrl);
	if(isAutoWidth){
		$('#hoverImage').css('width', 'auto');
		$('#hoverImage').css('height', '300px');
	}else{
		$('#hoverImage').css('width', '405px');
		$('#hoverImage').css('height', 'auto');
	}
	showModal('hover_image_div', true);
}
var isHoverVideo = false;
function hoverVideo(videoUrl){
	if(isHoverVideo || isHoveUserProfile) return;
	playVideo('hoverVideo', videoUrl, false);
	showModal('hover_video_div', true);
	isHoverVideo = true;
}

function deleteThisPhoto(isUser){
	if(isUser){
		if(jcrop_api)jcrop_api.destroy();
		$('.tr_img_upload').show();
		$('.tr_img_crop').hide();
		$('#crop_preview_usr').hide();
		$('#user_profile_photo_crop_div').hide();
		$('#user_profile_photo_upload_div').show();
		$('#selected_photo_file').text('No file selected');
		$("#" + form_id + " input[id=user_user_photo_photo]").val('');
		if($('#user_user_photo_id').length > 0) $('#user_user_photo_id').val('');
		if($('#user_edit_user_photo_id').length > 0) $('#user_edit_user_photo_id').val('');
		$('#error_explanation_epi').text('');
		if($('#user_profile_image').length > 0)$('#user_profile_image').attr('src', usr_prof_pic);
	}else{
		$('#browse_img_video').show();
		$('#preview_img_video').hide();
		$('#item_item_photo_photo').val('');
		$('#item_item_photo_id').val('');
		$('#selected_photo_file').text('No file selected');
		$('#upload_img_div').css('display', 'block');
		$('#tab1 a').text('Upload a Photo or Video');
		if(jcrop_api)jcrop_api.destroy();
		$('#crop_preview').hide();
		$('#on_web_div').show();
		$('.step2_preview_heading').show();
		$('.step3_preview_heading').hide();
		$('#preview_img_video').hide();
	}
	isCropping = false;
	return false;
}

function deleteThisVideo(){
	$('#browse_img_video').show();
	$('#preview_img_video').hide();
	jQuery('#selected_video_file').text('No file selected');
	$('#item_item_video_video').val('');
	$('#upload_img_div').css('display', 'none');
	$('#tab1 a').text('Upload a Photo or Video');
	
	return false;
}


function resetItemPhotoModal()
{
	$("#preview_img_video").hide();
	$('#browse_img_video').show();
	$("#player").html("");
	$("#player").hide();
	$("#preview_video").hide();
	$("#photo_upload_div").show();
	// $('#preview_img_video').hide();
	$('#item_item_photo_photo').val('');
	$('#item_item_photo_id').val('');
	$('#selected_photo_file').text('No file selected');
	$('#selected_video_file').text('No file selected');
	$('#upload_img_div').css('display', 'none');
	// $('#tab1 a').text('Upload a Photo or Video');
	if(jcrop_api)jcrop_api.destroy();
	$('#crop_preview').hide();
	$('#tradeya_img_prev_small').attr("src", "https://s3.amazonaws.com/tradeya_prod/tradeya/images/img_prev_default.png");
	$('#tradeya_img_prev').attr("src", "https://s3.amazonaws.com/tradeya_prod/tradeya/images/img_prev_default.png");
	$("#step2_web").hide();
	$("#step2_computer").hide();
	$("#step1_modal").show();
	$('#step1_upload').modal('hide');
}

function AddItemPhoto(url,photo_id)
{
	if(item_video_photo_count >= 4)
	{
		alert("You can upload maximum 4 images");
	}
	if(typeof(photo_id) == 'undefined')
		photo_id = $("#item_item_photo_id").val();
	var item_photo = {}
	item_photo["id"] = photo_id;
	item_photos.push(item_photo);
	item_video_photo_count++;
	var data = JSON.stringify(item_photos);
	$("#item_photos").val(data);
	var td = $(".active_image_upload").first().parents('td');
	td.html('<div id="upload_more" onmouseover="show_hover_on_image(this)" onmouseout="hide_hover_on_image(this)" class="image_uploaded upload_image_video" v=' + photo_id + ' data-id=' + photo_id + '><a href=\"#\" onclick=\"DeleteItemPhoto(this,'+photo_id+'); return false;\" class=\"image_uploaded_cross\">X</a><div class="add_photo_hover"></div><div class="inner_image_uploaded"><img src="' + url + '"></div><div class="drag_text">Drag to re-order</div></div></div>' );
	td.addClass('sortable');

	// $(".active_image_upload").first().html('<div id="upload_more" class="image_uploaded upload_image_video" v=' + photo_id + '><a href=\"#\" onclick=\"DeleteItemPhoto(this,'+photo_id+'); return false;\" class=\"image_uploaded_cross\">X</a><div class="inner_image_uploaded"><img src="' + url + '"></div></div>' );
	// $(".active_image_upload").parents('td').addClass('sortable');
	// $(".active_image_upload").attr('v', photo_id);
	// $(".active_image_upload").removeClass("active_image_upload");
	var img_div = $(".empty_image_upload").first();
	img_div.addClass("active_image_upload");
	img_div.removeClass("empty_image_upload");
	img_div.html('<a id="more_more_2" href="#photo_upload_modal" onclick=" return false;" data-toggle="modal" aria-labelledby="myModalLabel" class="add_photo_link"><img src="http://d3md9h2ro575fr.cloudfront.net/images/add_image.png"></a>');
	// var new_image = "<div id = 'photo_" + photo_id  + "' class=\"upload_image_video\"> <a href=\"#\" onclick=\"DeleteItemPhoto("+photo_id+"); return false;\" class=\"upload_cross\">X</a> <img src='" + url + "' /> </div>";
	// $("#user_uploaded_images").append(new_image);
	if(item_video_photo_count >= 4)
	{
		// alert("done");
		$("#photo_upload_modal").attr("data-toggle", "");
	}
	// $("#images_row" ).sortable( "refresh" );
}

function AddItemVideo(url,video_id)
{
	if(typeof(video_id) == 'undefined')
		video_id = $("#item_item_video_id").val();
	if(typeof(url) == 'undefined')
		url = $("#item_item_video_path").val();
	var item_video = {}
	item_video["id"] = video_id;
	item_videos.push(item_video);
	item_video_photo_count++;
	var data = JSON.stringify(item_videos);
	$("#item_videos").val(data);
	$('#crop_preview').hide();
	var new_vid = "<div id = 'video_" + video_id  + "' class=\"upload_image_video\"> <a href=\"#\" onclick=\" DeleteItemVideo(" + video_id + "); return false;\" class=\"upload_cross\">X</a> <a id = 'a_video_" + video_id  + "' src='" + url + "' /> </div>";
	$("#user_uploaded_images").append(new_vid);
	// $("#multiple_image_prev").prepend(new_vid);
	resetItemPhotoModal();
	if(item_video_photo_count >= 4)
	{
		$("#more_more").attr("data-toggle", "");
		$("#upload_more").hide();
	}
	playVideo('a_video_' + video_id, url, false); 

}

function DeleteItemPhoto(cross_a,photo_id)
{
	var i = 0;
	for(i; i < item_photos.length; i++)
	{
		if(item_photos[i].id == photo_id)
		{
			break;
		}
	}
	if(i < item_photos.length)
	{
		if (item_video_photo_count == 4)
		{
			$("#photo_upload_modal").attr("data-toggle", "modal");
			// $("#upload_more").show();
		}
		item_photos.splice(i,1);
		item_video_photo_count--;
		// $(".upload_image_video").first().
		var data = JSON.stringify(item_photos);
		$("#item_photos").val(data);
		$(cross_a).parents("td").remove();
 
		$("#images_row").append('<td><div id="upload_more" class="upload_image_video empty_image_upload"><img src="http://d3md9h2ro575fr.cloudfront.net/images/blank_image.jpg"></div></td>');
 
		if ($(".active_image_upload").length <= 0)
		{
			var img_div = $(".empty_image_upload").first();
			img_div.addClass("active_image_upload");
			img_div.removeClass("empty_image_upload");
			img_div.html('<a id="more_more_2" href="#photo_upload_modal" onclick=" return false;" data-toggle="modal" aria-labelledby="myModalLabel" class="add_photo_link"><img src="http://d3md9h2ro575fr.cloudfront.net/images/add_image.png"></a>');
			// img_div.html('<a id="more_more_2" href="#photo_upload_modal" onclick=" return false;" data-toggle="modal" aria-labelledby="myModalLabel" class="add_photo_link"><span>+</span><br />Add photo</a>');
		}

		$.ajax({
			type: "POST",
		  url: "/delete_item_photo",
		  data: { photo_id: photo_id },
		});
		// $("#photo_"+photo_id).remove();
	}
}

function DeleteVideoPhoto(video_id)
{
	var i = 0;
	for(i; i < item_videos.length; i++)
	{
		if(item_videos[i].id == video_id)
		{
			break;
		}
	}
	if(i < item_videos.length)
	{
		if(item_video_photo_count == 4)
		{
			$("#more_more").attr("data-toggle", "modal");
			$("#upload_more").show();
		}
		item_videos = item_videos.splice(i,0);
		item_video_photo_count--;
		var data = JSON.stringify(item_videos);
		$("#item_videos").val(data);
		$("#video_"+video_id).remove();
	}
}

function rearrangeItemPhotos()
{
	item_photos = [];
	var item_divs = $(".upload_image_video:not(.empty_image_upload,.active_image_upload)");
	for(var i=0;i<item_divs.length;i++)
	{
		if(typeof($(item_divs[i]).attr("v") != 'undefined') && ($(item_divs[i]).attr("v").length > 0) )
			{
				var item_photo = {}
				item_photo["id"] = $(item_divs[i]).attr("v");
				item_photos.push(item_photo);
				// item_photos[i] = $(item_divs[i]).attr("v");
			}
	}
	var data = JSON.stringify(item_photos);
	$("#item_photos").val(data);
}

function EditItemPhotos(item_id)
{
	item_photos = [];
	var item_divs = $(".upload_image_video:not(.empty_image_upload,.active_image_upload)");
		if(typeof($(item_divs[0]).attr("v") != 'undefined') && ($(item_divs[0]).attr("v").length > 0) )
			{
				var item_photo_id = $(item_divs[0]).attr("v");
				$.ajax({
					type: "POST",
				  url: "/items/"+item_id+"/main_photo",
				  data: { photo_id: item_photo_id },
				});
			}
	// }
	var data = JSON.stringify(item_photos);
	$("#item_photos").val(data);
}

function makeFieldBlank(formId, fldId){
	$('#' + formId + ' input[id=' + fldId + ']').val('');
}

function fillOfferForm(id){
	// if (e.preventDefault) { e.preventDefault(); } else { e.returnValue = false; }
	// e.stopPropagation();

	jQuery.ajax({
		url: "/offer_data?id=" + id,
		success: function(data){
			deleteThisPhoto();
			deleteThisVideo();
			offer = jQuery.parseJSON(data);
			$('#item_selected_item_id').val(offer.id);
			$('#item_title').val(offer.title);
			$('#item_desc').val(offer.desc);
			if(offer.photo){
				if(offer.photo.length > 0){
					var i =0;
					for(i=0;i<offer.photo.length;i++)
					{
						AddItemPhoto(offer.photo[i].url, offer.photo[i].id);
					}
				}
			}
			if(offer.video){
				if(offer.video.length > 0){
					var i =0;
					for(i=0;i<offer.video.length;i++)
					{
						AddItemPhoto(offer.video[i].url, offer.video[i].id);
					}
				}
			}
			if(offer.qty_unlimited && offer.qty_unlimited == true)
		 		$('#item_qty_unlimited').attr('checked','checked');
			else
		 		$("#item_quantity").val(offer.quantity);
			// $('#item_is_tod').val(offer.tod);
			// $('#subcat_item_' + offer.category_id).click();
			// if(offer.photo){
			// 	if(offer.photo.file_name.length > 0){
			// 		$('#selected_photo_file').text(offer.photo.file_name);
			// 		$('#tradeya_img_prev').attr('src', offer.photo.url);

			// 		jQuery('#browse_img_video').hide();
			// 		jQuery('#preview_img_video').show();

			// 		jQuery('#file_type_photo').click();
			// 	}else{
			// 		jQuery('#browse_img_video').show();
			// 		jQuery('#preview_img_video').hide();
			// 	}
			// }else if(offer.video){
			// 	jQuery('#file_type_video').click();
			// 	$('#selected_video_file').text(offer.video.file_name);
			// 	playVideo('player', offer.video.url, false);

			// 	$('#rotate_preview').hide();
			// 	jQuery('#browse_img_video').hide();
			// 	jQuery('#preview_img_video').show();
			// }
			// if($('#tr_mlt_time').length > 0){
			// 	if(offer.is_single_tradeya == 1 || offer.is_single_tradeya == true){
			// 		$('#multi_trade_img').attr('src','https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/checkbox_filled.png');
			// 		$('#tr_mlt_time').attr('checked','checked');
			// 	}else{
			// 		$('#multi_trade_img').attr('src','https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/checkbox.png');
			// 		$('#tr_mlt_time').removeAttr('checked');
			// 	}
			// }
			jQuery("#offer_title_dropdownbox").hide();
			jQuery("#offer_title_resultdiv").hide();
			if(jcrop_api)jcrop_api.destroy();
			$('#crop_preview').hide();
		}
	});
	return false;
}

function fillItemWantsForm(id){
	jQuery.ajax({
		url: "/item_want_data?id=" + id,
		success: function(data){
			itemWant = jQuery.parseJSON(data);
			$('#item_item_want_title').val(itemWant.title);
			$('#item_item_want_desc').val(itemWant.desc);
			$('#item_want_cat_' + itemWant.category_id).click();
			jQuery("#item_want_title_dropdownbox").hide();
			jQuery("#item_want_title_resultdiv").hide();
		}
	});
	return false;
}

var lockHeaderAjaxCall=false;
var otAjaxSearch='';
function myOfferTitles(e){
	if (e.preventDefault) { e.preventDefault(); } else { e.returnValue = false; }
	if (e.keyCode == 13) { // No need to do browser specific checks. It is always 13.
		jQuery('#winespinner').hide();
		jQuery("#offer_title_dropdownbox").hide();
		jQuery("#offer_title_resultdiv").hide();
		return false;
	}
	if(jQuery("#item_title").val().length > 0 && (e.which != 27) && (e.which != 38)){
		if (lockHeaderAjaxCall == true && otAjaxSearch != ""){
			otAjaxSearch.abort();
			lockHeaderAjaxCall = false;
		}
		jQuery('li.li_offer_title').remove();
		jQuery('#ul_offer_title_list').empty();
		jQuery('#winespinner').show();
		jQuery("#offer_title_dropdown-body").css('height','11px');
		jQuery("#offer_title_dropdownbox").show();
		jQuery("#offer_title_resultdiv").hide();
		otAjaxSearch = jQuery.ajax({
			cache: true,
			url: "/search_my_offer?title=" + encodeURIComponent(jQuery("#item_title").val()),
			beforeSend: function ( xhr ) {
				lockHeaderAjaxCall = true;
			},
			success: function(data){
				if(data == "[]"){
					jQuery('#ul_offer_title_list').empty();
					jQuery("#offer_title_dropdownbox").hide();
					jQuery('#winespinner').hide();
					jQuery("#offer_title_dropdown").hide();
				}else{
					jQuery('#ul_offer_title_list').empty();
					jQuery('#winespinner').hide();
					titleArr = jQuery.parseJSON(data);
					if (titleArr.length < 80){
						jQuery("#offer_title_dropdown-body").css('height', titleArr.length*22+'px');
						jQuery("#offer_title_dropdown-body").css('overflow-y','visible');
					}else{
						jQuery("#offer_title_dropdown-body").css('height','500px');
						jQuery("#offer_title_dropdown-body").css('overflow-y','auto');
					}
		
					var ni = document.getElementById('ul_offer_title_list');
					for (i=0;i<=titleArr.length-1;i++){
						var newdiv = document.createElement('li');
						dspname = "";
						dspname = titleArr[i].title;
						newdiv.setAttribute('id', 'ot_'+i);
						newdiv.setAttribute('style', 'cursor:pointer');
						newdiv.setAttribute('onKeyDown', "updowntop('ot_"+i+"',event)");
						newdiv.setAttribute('onclick', "fillOfferForm(event, '"+titleArr[i].id+"')");
						newdiv.setAttribute('onfocus', "$('.li_offer_title').css('background-color','#fff');$(this).css('background-color','#ccc')");
						newdiv.setAttribute('onmouseover', "$(this).focus();");
						newdiv.setAttribute('class', "li_offer_title");
						newdiv.innerHTML = "<a style='text-decoration:none; color: #777;font-size: 13px;'href=\"#\" onclick=\"return false;fillOfferForm(\'"+titleArr[i].id+"\');\">"+dspname+'<span style="color: #bbb;">'+titleArr[i].status+'</span></a>';
						ni.appendChild(newdiv);
					}
					jQuery('#winespinner').hide();
					jQuery("#offer_title_resultdiv").show();
				}
			},
			complete: function(){
				lockHeaderAjaxCall = false;
			}
		});	
	}else{
		jQuery('#winespinner').hide();
		jQuery("#offer_title_dropdownbox").hide();
		jQuery("#offer_title_resultdiv").hide();
	}
}

function myItemWantTitles(e){
	if (e.preventDefault) { e.preventDefault(); } else { e.returnValue = false; }
	if (e.keyCode == 13) { // No need to do browser specific checks. It is always 13.
		jQuery('#item_want_winespinner').hide();
		jQuery("#item_want_title_dropdownbox").hide();
		jQuery("#item_want_title_resultdiv").hide();
		return false;
	}
	if(jQuery("#item_item_want_title").val().length > 0 && (e.which != 27) && (e.which != 38)){
		if (lockHeaderAjaxCall == true && otAjaxSearch != ""){
			otAjaxSearch.abort();
			lockHeaderAjaxCall = false;
		}
		jQuery('li.li_offer_title').remove();
		jQuery('#ul_item_want_title_list').empty();
		jQuery('#item_want_winespinner').show();
		jQuery("#item_want_title_dropdown-body").css('height','11px');
		jQuery("#item_want_title_dropdownbox").show();
		jQuery("#item_want_title_resultdiv").hide();
		otAjaxSearch = jQuery.ajax({
			cache: true,
			url: "/search_my_item_wants?title=" + encodeURIComponent(jQuery("#item_item_want_title").val()),
			beforeSend: function ( xhr ) {
				lockHeaderAjaxCall = true;
			},
			success: function(data){
				if(data == "[]"){
					jQuery('#ul_item_want_title_list').empty();
					jQuery("#item_want_title_dropdownbox").hide();
					jQuery('#item_want_winespinner').hide();
					jQuery("#item_want_title_dropdown").hide();
				}else{
					jQuery('#ul_item_want_title_list').empty();
					jQuery('#item_want_winespinner').hide();
					titleArr = jQuery.parseJSON(data);
					if (titleArr.length < 80){
						jQuery("#item_want_title_dropdown-body").css('height', titleArr.length*22+'px');
						jQuery("#item_want_title_dropdown-body").css('overflow-y','visible');
					}else{
						jQuery("#item_want_title_dropdown-body").css('height','500px');
						jQuery("#item_want_title_dropdown-body").css('overflow-y','auto');
					}
		
					var ni = document.getElementById('ul_item_want_title_list');
					for (i=0;i<=titleArr.length-1;i++){
						var newdiv = document.createElement('li');
						dspname = "";
						dspname = titleArr[i].title;
						newdiv.setAttribute('id', 'ot_'+i);
						newdiv.setAttribute('style', 'cursor:pointer');
						newdiv.setAttribute('onKeyDown', "upDownTopItemWants('ot_"+i+"',event)");
						newdiv.setAttribute('onclick', "fillItemWantsForm('"+titleArr[i].id+"')");
						newdiv.setAttribute('onfocus', "$('.li_offer_title').css('background-color','#fff');$(this).css('background-color','#ccc')");
						newdiv.setAttribute('onmouseover', "$(this).focus();");
						newdiv.setAttribute('class', "li_offer_title");
						newdiv.innerHTML = "<a style='text-decoration:none; color: #777;font-size: 13px;'href=\"#\" onclick=\"return false;fillItemWantsForm(\'"+titleArr[i].id+"\');\">"+dspname+'<span style="color: #bbb;">'+titleArr[i].status+'</span></a>';
						ni.appendChild(newdiv);
					}
					jQuery('#item_want_winespinner').hide();
					jQuery("#item_want_title_resultdiv").show();
				}
			},
			complete: function(){
				lockHeaderAjaxCall = false;
			}
		});	
	}else{
		jQuery('#item_want_winespinner').hide();
		jQuery("#item_want_title_dropdownbox").hide();
		jQuery("#item_want_title_resultdiv").hide();
	}
}

function movesearchedown(event){
	if (event.keyCode == 40){
		if (event.preventDefault) { event.preventDefault(); } else { event.returnValue = false; }
		$("#ul_offer_title_list li a:first").focus();
	}
	return false;
}

function moveSearchDownItemWant(event){
	if (event.keyCode == 40){
		if (event.preventDefault) { event.preventDefault(); } else { event.returnValue = false; }
		$("#ul_item_want_title_list li a:first").focus();
	}
	return false;
}

function updowntop(id, event){
	if (event.keyCode == 40){
		if (event.preventDefault) { event.preventDefault(); } else { event.returnValue = false; }
		var idStr = id.split('_');
		idStr[1] = parseInt(idStr[1])+1
		$("#"+idStr[0]+"_"+idStr[1]+" a").focus();
	}
	if (event.keyCode == 38){
		if (event.preventDefault) { event.preventDefault(); } else { event.returnValue = false; }
		var idStr = id.split('_');
		if (parseInt(idStr[1]) == 0){
			if (idStr[0] == "ot"){$("#item_title").focus();}
		}else{
			idStr[1] = parseInt(idStr[1])-1
			$("#"+idStr[0]+"_"+idStr[1]+" a").focus();
		}
	}
	return false;
}

function upDownTopItemWants(id, event){
	if (event.keyCode == 40){
		if (event.preventDefault) { event.preventDefault(); } else { event.returnValue = false; }
		var idStr = id.split('_');
		idStr[1] = parseInt(idStr[1])+1
		$("#"+idStr[0]+"_"+idStr[1]+" a").focus();
	}
	if (event.keyCode == 38){
		if (event.preventDefault) { event.preventDefault(); } else { event.returnValue = false; }
		var idStr = id.split('_');
		if (parseInt(idStr[1]) == 0){
			if (idStr[0] == "ot"){$("#item_item_want_title").focus();}
		}else{
			idStr[1] = parseInt(idStr[1])-1
			$("#"+idStr[0]+"_"+idStr[1]+" a").focus();
		}
	}
	return false;
}

var imgOrigWidth = 1;
var imgCropLargeWidth = 1;
var imgCropLargeHeight = 1;
var jcrop_api = null;
var itemPhotoId = 0;
var isCropping = false;
var preview_w = 0;
var preview_h = 0;
var showCropPreview = false;
var form_id;
var imgRatio = 1.32;
// function cropReady(id, origW, cropLargeW, cropLargeH, prevW, prevH, cropPreview, formId, isItemImg){
// 	imgOrigWidth = origW;
// 	imgCropLargeWidth = cropLargeW;
// 	imgCropLargeHeight = cropLargeH;
// 	preview_w = prevW;
// 	preview_h = prevH;
// 	showCropPreview = cropPreview;
// 	form_id = formId;

// 	if(showCropPreview)$('#crop_preview').show();
// 	$('#browse_img_video').hide();
// 	$('#on_web_div').hide();
// 	$('.step2_preview_heading').hide();
// 	$('.step3_preview_heading').show();
// 	$('#preview_img_video').show();

// 	if(!isItemImg){
// 		$('.tr_img_upload').hide();
// 		$('.tr_img_crop').show();
// 		$('#user_profile_photo_upload_div').hide();
// 		$('#user_profile_photo_crop_div').show();
// 	}
// 	jcrop_api = $.Jcrop($('#' + id),{
// 		onChange: update_crop,
// 		onSelect: update_crop,
// 		setSelect: [0, 0, preview_w, preview_h],
// 		minSize: [preview_w, preview_h],
// 		aspectRatio: (preview_w * 1.0)/preview_h
// 	});
// 	isCropping = true;
// 	var tW = 0;
// 	var tH = 0;
// 	var tR = 0.0;
// 	tR = (imgCropLargeWidth * 1.0) / (imgCropLargeHeight * 1.0);
// 	if(tR > imgRatio){
// 		tH = imgCropLargeHeight;
// 		tW = (imgCropLargeWidth * imgRatio);
// 	}else{
// 		tH = (imgCropLargeHeight * imgRatio);
// 		tW = imgCropLargeWidth;
// 	}
// 	jcrop_api.setSelect([0,0,tW,tH]);
// }

// function update_crop(coords) {
// 	if(showCropPreview){
// 		var rx = (preview_w * 1.0)/coords.w;
// 		var ry = (preview_h * 1.0)/coords.h;
// 		$('#tradeya_img_prev_small').css({
// 			width: Math.round(rx * imgCropLargeWidth) + 'px',
// 			height: Math.round(ry * imgCropLargeHeight) + 'px',
// 			marginLeft: '-' + Math.round(rx * coords.x) + 'px',
// 			marginTop: '-' + Math.round(ry * coords.y) + 'px'
// 		});
// 	}
// 	var ratio = (imgOrigWidth * 1.0) / imgCropLargeWidth;
// 	$("#" + form_id + " input[id=crop_x]").val(Math.round(coords.x * ratio));
// 	$("#" + form_id + " input[id=crop_y]").val(Math.round(coords.y * ratio));
// 	$("#" + form_id + " input[id=crop_w]").val(Math.round(coords.w * ratio));
// 	$("#" + form_id + " input[id=crop_h]").val(Math.round(coords.h * ratio));
// }

// var cropStarted = false;
// function cropImage(itemPhotoId, img_preview_id, isItemPhoto){
// 	if (cropStarted) return false;
// 	if($("#" + form_id + " input[id=crop_w]").val() == 0 || $("#" + form_id + " input[id=crop_h]").val() == 0) {
// 		alert('Please select image to crop.');
// 		return false;
// 	}

// 	if(form_id == "user_profile_photo") jQuery("#ind_user_prof_img_crop").show();
// 	cropStarted = true;
// 	$('#ind_tradeya_img_prev').show();
// 	jQuery.ajax({
// 		type: "POST",
// 		url: "/crop_image",
// 		data: "id=" + jQuery('#' + itemPhotoId).val() + "&is_item_photo=" + (isItemPhoto ? "true" : "false") + "&ip[crop_x]=" + $("#" + form_id + " input[id=crop_x]").val() + "&ip[crop_y]=" + $("#" + form_id + " input[id=crop_y]").val() + "&ip[crop_w]=" + $("#" + form_id + " input[id=crop_w]").val() + "&ip[crop_h]=" + $("#" + form_id + " input[id=crop_h]").val(),
// 		success: function(data){
// 			jcrop_api.destroy();
// 			photo = jQuery.parseJSON(data);
// 			if(isItemPhoto){
// 				$('#crop_preview').hide();
// 				AddItemPhoto(photo.url);
// 				resetItemPhotoModal();
// 				// item_photos_count ++;
// 				// item_photo_ids += (((item_photo_ids.length>1)? "," : "") + jQuery('#' + itemPhotoId).val());
// 				// $("#item_photos").val(item_photo_ids);
// 				// reset modal
// 			}else{
// 				$('.tr_img_upload').show();
// 				$('.tr_img_crop').hide();
// 				$('#user_profile_photo_crop_div').hide();
// 				$('#user_profile_photo_upload_div').show();
// 				$('#' + img_preview_id).attr('src', photo.url);
// 			}
// 			if(form_id == "user_profile_photo") editProfileImage();

// 			isCropping = false;
// 		},
// 		complete: function(){
// 			cropStarted = false;
// 			$('#ind_tradeya_img_prev').hide();
// 		}
// 	});
// 	return false;
// }
var isRotating = false;
function rotateVideo(direction){
	if(isRotating) return false;
	jQuery('#video_rotate_spinner').show();
	isRotating = true;
	jQuery.ajax({
		type: "POST",
		url: "/rotate_video",
		data: "id=" + jQuery('#item_item_video_id').val() + "&direction=" + direction,
		success: function(data){
			playVideo('player', data, true);
			isRotating = false;
			jQuery('#video_rotate_spinner').hide();
		}
	});
}
var isCancelSubmitOffer = false;
function submitOfferCancel(){
	isCancelSubmitOffer = true;
	jQuery('#image_spinner').hide();
	jQuery('#video_spinner').hide();

	jQuery('#your_offer_form_div').hide();
	jQuery('.makeofferclicked_btn').hide();
	jQuery('.makeoffer_btn').show();
	jQuery('#spambot_div').text('');
	jQuery('#item_title').val('Write a title for your good or service here...');
	jQuery('#item_desc').val('Add more details about your good or service here...');
	jQuery('#choose_cat').text('Choose a category');
	jQuery('#selected_photo_file').text('No file selected');
	jQuery('#spambot_chkbox_image').attr('src', 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/checkbox.png');

	deleteThisPhoto();
	deleteThisVideo();
	

	return false;
}

//TODO change as per new code
//function get_next_page_items(page,total,user,category,search_txt,zip,distance)
function get_next_page_items(page,total,category,search_txt,sort_by)
{
	if (((page*pageSize) < total) && !isLoadingNextPage)
	{
		//_kmq.push(['record', 'Scroll items on browse page',{ 'SignedIn' : get_KMSignedIn()}]); 
		//_gaq.push(['_trackEvent', 'Activity', 'Scroll_browse', 'Scroll items on browse page']);
		page = page + 1;
		$('#items_spinner').show();
		
		isLoadingNextPage = true;
		jQuery.ajax({
			url: "/items",
			// data: "page=" + page + ((typeof(user)=='undefined')? "" : "&u="+user) + ((typeof(category)=='undefined')? "" : "&category="+category) + ((typeof(search_txt)=='undefined')? "" : "&search="+search_txt) + (((typeof(zip)=='undefined') || zip.length <= 0 || (typeof(distance) == 'undefined'))? "" : "&location_search=1&zipcode="+zip+"&distance="+distance),
			data: "page=" + page + ((typeof(category)=='undefined')? "" : "&category="+category) + ((typeof(search_txt)=='undefined')? "" : "&search="+search_txt) + ((typeof(sort_by)=='undefined')? "" : "&sort_by="+sort_by),
			success: function(data){
				isLoadingNextPage = false;
				$('#items_spinner').hide();
			},
			error: function(){
				$('#items_spinner').hide();
			},
			complete: function(){
				isLoadingNextPage = false;
				$('#items_spinner').hide();
			}
		});
		return page;
	}
	else
		return page;
}

//TODO remove commented code for version2
function submitItemSearchForm(){
	var search = $('#search_text').val().trim();
	// var zip = $('#zipcode_text').val().trim();
	var regexnum = /(^\d{5}(-\d{4})?$)|(^[ABCEGHJKLMNPRSTVXY]\d[A-Z]( )?\d[A-Z]\d$)/i;
	if(search == null || search == "" || search == "Search Keyword" || search.length <= 0){
		$('#search_error').text("Enter search keyword.");
	// }else if (($('#location_search').attr("checked") == "checked") && (zip == null || zip == "" || zip == "Zip Code" || zip.length <= 0)){
			// $('#search_error').text('zip code should not be empty.');
	// }else if (($('#location_search').attr("checked") == "checked") && (zip.match(regexnum) == null)){
			// $('#search_error').text('zip code format not valid.');
	}else{
		// _kmq.push(['record','Browse Side Nav Search Keyword button', {'Search string':search , 'SignedIn' : get_KMSignedIn()}])
		// _gaq.push(['_trackEvent', 'Activity', 'Clk_search', search]);
		$('#itemsSearchForm').submit();
	}

	return false;
}

function searchItemsOnEnter(event,test){
	if (event.keyCode == 13) { 
	// No need to do browser specific checks. It is always 13.
		if (event.preventDefault) { event.preventDefault(); } 
		event.preventDefault();
		setTimeout(function(){
		mixpanel.track( 'search ' + test + ' from top nav');
		// _gaq.push(['_trackEvent', 'Activity', 'Search', 'search ' + test + ' from top nav']);
		submitItemSearchForm();
		},900);
	}
}

function callHoverProfile(uid)
{
	if (uid)
	{
		jQuery.ajax({
		url: "/getUserData.js",
		data: "id="+uid,
		success: function(msg, status, xhr){
			}
		 });
	}
}
function updateDistance(itm_ids, id_prefix,zip){
	jQuery.ajax({
		url: "/items_distance",
		data: "ids=" + itm_ids + ((zip.length > 0)? "&zip="+zip : ""),
		success: function(data, status, xhr){
			dis_data = jQuery.parseJSON(data);
			for (i=0;i<=dis_data.length-1;i++){
				jQuery("#" + id_prefix + dis_data[i][0]).html(dis_data[i][1] + " miles");
			}
		},
		error: function(xhr, status){
		}
	});
}

function showMakeOfferBtn(itm_ids, id_prefix){
	jQuery.ajax({
		url: "/get_user_tradeyas",
		success: function(data, status, xhr){
			usr_trd = jQuery.parseJSON(data);
			for (i=0;i<=usr_trd.length-1;i++){
				jQuery("#" + id_prefix + usr_trd[i]).html("");}
			$('.offer_btns').show();
		},
		error: function(xhr, status){
		}
	});
}
function resetPhotoVideoModal(){
	$('#step1_modal').show();
	$('#step2_web').hide(); 
	$('#step2_computer').hide();
	$('#preview_img_video').hide();
}
function resetWebButton(){
	$('#step2_web').show();
	$('#step1_modal').hide(); 
	$('#on_web_div').show(); 
	$('#upload_img_div').show(); 
	$('.step3_preview_heading').hide(); 
	$('.step2_preview_heading').show(); 
}
function resetComputerButton(){
	$('#step2_computer').show();
	$('#step1_modal').hide(); 
	$('#step2_web').hide(); 
	$('#on_web_div').show(); 
	$('#upload_img_div').show(); 
	$('.step3_preview_heading').hide(); 
	$('.step2_preview_heading').show(); 
}

function ask_question(){
	var comments_div = $(".comments_form").first();
	if(comments_div.length > 0)
	{
		var comments_div_id = comments_div.attr("id");
		// if it is a private conversation, open the current offer div
		if (comments_div_id.indexOf("private") >= 0 )
		{
			$("#current_offer").removeClass('hidedrop');
			$("#offers_section_current img").attr('src','https://s3.amazonaws.com/tradeya_prod/tradeya/images/arrow_open.png');
			$('#confrm_select_div').show();
		}
		else
		{
			// else open public comments div
			$("#comments_table").removeClass('hidedrop');
			$("#comments_heading img").attr('src','https://s3.amazonaws.com/tradeya_prod/tradeya/images/arrow_open.png');
		}
		customScroll("#" + comments_div_id);
	}
	return false;
}

function item_tab_selected(a_tag){
	$('.item-tabs li').removeClass('active');
	$(a_tag).parent().addClass('active');
}
	
function show_hover_on_image(div){
	$(div).children(".add_photo_hover").show();
  $(div).children(".image_uploaded_cross").show();
  var did=$(div).data("id");
  $("#edit_link_"+did).show();
  // $(".edit_links_wrapper a").show();

}
	
function hide_hover_on_image(div){
	$(div).children(".add_photo_hover").hide();
  $(div).children(".image_uploaded_cross").hide();
  // var did=$(div).data("id");
  // $("#edit_link_"+did).css("visibility","hidden");
  $(".edit_links_wrapper a").hide();
}

 function onlink_over(div){
 	$(div).show();
 } 
 function onlink_out(div){
 	$(div).hide();
 } 
	
	
	
	