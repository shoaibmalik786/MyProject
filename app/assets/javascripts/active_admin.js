
$(function(){
  $('li#mail_submit_action input').click(function(){
  	if($('#mail_to_all_users').is(':checked')){
	    var response = confirm("Are you sure, you want to send this mail to ALL the users in the system?");
	    if(response){
	      return true;
	    }
	    $('#mail_to_all_users').attr("checked", false);
	    return true;
  	}
  });
});
