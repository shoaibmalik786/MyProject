// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

function seeMoreAlerts(q){
	jQuery.ajax({
		url:"/dashboard.js?" + q,
		success: function(msg, status, xhr){
			
		}
	});
	return false;
}
function filterAlerts(fi, alert_type){
	$('#a_alert_filter').text($(fi).text());
	$('#filter_dropdown').toggleClass('hidedrop');

	jQuery.ajax({
		url:"/dashboard.js?alert_filter=" + alert_type,
		success: function(msg, status, xhr){
			
		}
	});
	return false;
}
var prevAlertId = 0;
function markAlertAndRedirect(id, redirect_url){
	if((prevAlertId == id || id == 0) && redirect_url != undefined){
		document.location = redirect_url;
	}else if(prevAlertId == id || id == 0){
		return;
	}else{
		prevAlertId = id;
		jQuery.ajax({
			url: "/mark_alert_read_and_redirect.js?id=" + id,
			success: function(msg, status, xhr){
				if(redirect_url != undefined){
					document.location = redirect_url;
				}
			}
		});
	}
	return false;
}
function refreshAlertCountAndShowNew(){
	if(isPageActive){
		jQuery.ajax({
			url: "/refresh_alert_count_and_show_new.js",
			success: function(msg, status, xhr){
				
				setTimeout(function() {refreshAlertCountAndShowNew();}, 9000);
			}
		});
	}else{
		setTimeout(function() {refreshAlertCountAndShowNew();}, 9000);
	}
}
function refreshNotificationCountOnGreet(once){
	if(isPageActive){
		jQuery.ajax({
			url: "/refresh_user_greet_notification_count.js",
			success: function(msg, status, xhr){
				if(!once)setTimeout(function() {refreshNotificationCountOnGreet();}, 10000);
			}
		});
	}else{
		if(!once)setTimeout(function() {refreshNotificationCountOnGreet();}, 10000);
	}
}

function contestFBShare(){
	jQuery.ajax({
		url: "/contest_share",
		method: "POST",
		success: function(data){				
		},
		error: function(data){
		}
	});
}
