var isLoadingNextPage = false;
var pageSize=20;

function get_next_page_users(page,total,search_txt,sort_by)
{
	if (((page*pageSize) < total) && !isLoadingNextPage)
	{
		page = page + 1;
		$('#items_spinner').show();
		
		isLoadingNextPage = true;
		jQuery.ajax({
			url: "/users",
			data: "page=" + page + ((typeof(search_txt)=='undefined')? "" : "&search="+search_txt) + ((typeof(sort_by)=='undefined')? "" : "&sort_by="+sort_by),
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

function clickProfileImage(imgUrl){
  $("#profile_large_image img").attr('src', imgUrl);
}

function AddUserPhoto(url,photo_id)
{
	if(user_photo_count >= 4)
	{
		alert("image limit reached");
	}
	if(typeof(photo_id) == 'undefined')
		photo_id = $("#user_user_photo_id").val();
	var td = $(".active_image_upload").first().parents('td');
	td.html('<div id="upload_more" onmouseover="show_hover_on_image(this)" onmouseout="hide_hover_on_image(this)" class="image_uploaded upload_image_video" v=' + photo_id + ' data-id=' + photo_id + '><a href=\"#delete_modal\" data-toggle=\"modal\" onclick=\"$(\'#user_photo_id\').val(' + photo_id + '); return false;\" class=\"image_uploaded_cross\">X</a><div class="inner_image_uploaded" ><img src="' + url + '"></div><div class="drag_text">Drag to re-order</div></div>' );
	td.addClass('sortable');

	var img_div = $(".empty_image_upload").first();
	img_div.addClass("active_image_upload");
	img_div.removeClass("empty_image_upload");
	img_div.html('<a id="more_more_2" href="#photo_upload_modal" onclick=" return false;" data-toggle="modal" aria-labelledby="myModalLabel" class="add_photo_link"><img src="http://d3md9h2ro575fr.cloudfront.net/images/add_image.png"></a>');
	if(user_photo_count >= 4)
	{
		$("#photo_upload_modal").attr("data-toggle", "");
	}
	
}

function DeleteUserPhoto(photo_id){
	// $("#delete_modal").modal('hide');
	var photo_div = $("[v=" + photo_id+"]");
	if(photo_div.length > 0)
	{
		user_photo_count--;
		$(photo_div).parents("td").remove();
 
		$("#user_images_row").append('<td><div id="upload_more" class="upload_image_video empty_image_upload"><img src="http://d3md9h2ro575fr.cloudfront.net/images/blank_image.jpg"></div></td>');

		if ($(".active_image_upload").length <= 0)
		{
			var img_div = $(".empty_image_upload").first();
			img_div.addClass("active_image_upload");
			img_div.removeClass("empty_image_upload");
			img_div.html('<a id="more_more_2" href="#photo_upload_modal" onclick=" return false;" data-toggle="modal" aria-labelledby="myModalLabel" class="add_photo_link"><img src="http://d3md9h2ro575fr.cloudfront.net/images/add_image.png"></a>');
		}
	}
}

function rearrangeUserPhotos(user_id)
{
	user_photos = [];
	var user_divs = $(".upload_image_video:not(.empty_image_upload,.active_image_upload)");
	// for(var i=0;i<user_divs.length;i++)
	// {
		if(typeof($(user_divs[0]).attr("v") != 'undefined') && ($(user_divs[0]).attr("v").length > 0) )
			{
				var user_photo_id = $(user_divs[0]).attr("v");
				// var user_photo = {};
				// user_photo["id"] = $(user_divs[i]).attr("v");
				// user_photos.push(user_photo);
				$.ajax({
					type: "POST",
				  url: "/users/"+user_id+"/user_main_photo",
				  data: { photo_id: user_photo_id },
				});
			}
	// }
	var data = JSON.stringify(user_photos);
	$("#user_photos").val(data);
}

function MoreLess(){
	var h = $('.rating_text')[0].scrollHeight;
	var showChar = 278;
	var t_text=$(".rating_text").text();
	if(t_text.length>showChar){
	    	var small_text=t_text.substr(0,showChar)+'...';
	    	$(".rating_text").html(small_text);
	    	$('a.hide_text').hide();
	    }
	    else{
	    	$(".rating_text").html(t_text);
	    	$("a.hide_text").hide();
	    	$('a.show_text').hide();
	    }
	// $("a.hide_text").hide();
	$('a.show_text').click(function(e) {
	    e.stopPropagation();
	    $(".rating_text").html(t_text);
	    $('.rating_text').animate({
	    		'height': h
	    });
	    $('.profile_tab_wrapper').css('margin-top','0px');
	   
	    $(this).hide();
	    $("a.hide_text").show();
	    $("a.hide_text").css("float","right");
	    $("a.hide_text").css("font-size","11px");
	});

	$("a.hide_text").click(function(e) {
	    e.stopPropagation();
	    $(".rating_text").html(small_text);
	    $('.rating_text').animate({
	        'height': '164px'
	    });
	    
	    $(this).hide();
	    $("a.show_text").show();
	    // $('.profile_tab_wrapper').css('margin-top','-38px');
	})
}

function checkInviteForm(){
	var regex ="^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$";
	var regex_name = "^([a-zA-Z\s\-]*)$"
  if(document.getElementById('user_first_name').value == ''){
    $('#error_invite_msg').show();
    $('#error_invite_msg').text('First name cannot be empty');
    return false;
	}else if (document.getElementById('user_first_name').value.match(regex_name) == null){
		$('#error_invite_msg').show();
		$('#error_invite_msg').text('First name format not correct');
		return false;
  }else if(document.getElementById('user_email').value == ''){
    $('#error_invite_msg').show();
    $('#error_invite_msg').text('Email address cannot be empty');
    return false;
  }else if(document.getElementById('user_email').value.match(regex) == null){
  	$('#error_invite_msg').show();
    $('#error_invite_msg').text('Email address format not correct');
    return false;
  }else{
  	var email = document.getElementById('user_email').value;
    var data = 'user[email]='+ email;
    $.ajax({
      type: "GET",
      url: "/users/check_email",
      data: data,
      success: function(data) {
        $('#error_invite_msg').show();
        $('#error_invite_msg').text('Email already exists');
        return false;
      },
      error: function(data) {
        _gaq.push(['_trackEvent', 'Invite Friends', 'Clk_Send', 'Click Send on Invite Friends Page']);
		  	mixpanel.track('Click Send on Invite Friends Page'); 
		    setTimeout(function() {$('#new_user').submit();}, 1000);
      }
    });
  	
  }
}

//Deleting activities from dashboard
function delete_dashboard_item(path, item_id) {
    jQuery.ajax({
        type: "POST",
        url: path,
        data: null,
        success: function(msg, status, xhr) {
        	$("#"+ item_id).hide();
        },
        error: function(xhr, status) {
        }
    });
}