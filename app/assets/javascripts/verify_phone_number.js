// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

function verifyViaCall(){
    var phone_number = $('#phone_number').val();
    if(phone_number.length == 0 || phone_number.length < 10){
        // showModal('phonenotvalid');
        alert("Please enter a valid phone number.");
        $('#phone_number').focus();
        return;
    }
    jQuery.ajax({
        type: "POST",
        url: "/verify_phone_number",
        data: "phone_number=" + encodeURIComponent(phone_number),
        success: function(msg, status, xhr){
            if(msg == "CALL Failed"){
                // showModal('phonenotvalid');
                alert("Please enter a valid phone number.");
                $('#phone_number').focus();
            }else if(msg == "Already verified!"){
                alert("Phone number already verified!");
                $('#phone_number').focus();
            }else{
                alert("Calling on " + phone_number + ". Please enter the code in the box below.")
                $(".pin_resend").show();
                $(".ph_verify_submit").show();
                $(".confirm_box").show();
                $("p.c_input span.ph_verify").hide();
                $("#verification_options").hide();

            }
        }
    });
}

var callStatusCounter = 0;
function checkCallStatus(id){
    callStatusCounter = callStatusCounter + 1;
    jQuery.ajax({
        url: "/twilio_call_verification_status?id=" + id,
        success: function(msg, status, xhr){
            if(msg == "Success"){
                document.location.reload();
            }else if(callStatusCounter <= 8){
                setTimeout(function() {checkCallStatus(id);}, 3000);
            }else{
                alert("Verification failed! Try again.");
                cancelVerification();
            }
        }
    });
}

function verifyViaSMS(){
    var phone_number = $('#phone_number').val();
    if(phone_number.length == 0 || phone_number.length < 10){
        // $('#phonenotvalid').modal('show');
        alert("Please enter a valid phone number.");
        $('#phone_number').focus();
        return;
    }
    jQuery.ajax({
        url: "/send_verification_code_via_sms?phone_number=" + encodeURIComponent(phone_number),
        success: function(msg, status, xhr){
            if(msg == "failed"){
                // $('#phonenotvalid').modal('show');
                alert("Please enter a valid phone number.");
                $('#phone_number').focus();
            }else if(msg == "Already"){
                alert("Phone number already verified!");
                $('#phone_number').focus();
            }else{
                // $('#verification_sms_div_title').text('We’ll send a TradeYa Verification Code in the next few minutes to ' + phone_number + ". Please enter it in the box below.");
                // $('.verification_sms_call').css('display','block');
                // alert("We’ll send a TradeYa Verification Pin in the next few minutes to " + phone_number + ". Please enter it in the box below.")
                // $("#resend_modal").modal('show');
                $(".pin_resend").show();
                $(".ph_verify_submit").show();
                $(".confirm_box").show();
                $("p.c_input span.ph_verify").hide();
                $("#verification_options").hide();
            }
        }
    });
}

function verifyPhoneNumber(){
    var verification_code = $('#verification_code').val();
    var phone_number = $('#phone_number').val();
    jQuery.ajax({
        url:"/verify_phone_number_via_sms?phone_number=" + encodeURIComponent(phone_number) + "&verification_code=" + encodeURIComponent(verification_code),
        success: function(msg, status, xhr){
            if(msg == "Verified"){
                $(".pin_resend").hide();
                $(".ph_verify_submit").hide();
                $(".confirm_box").hide();
                $("p.c_input span.ph_verify").hide();
                $(".ph_no_remove").show();
                $("#verification_options").hide();
                alert("Phone number has been successfully verified");
            }else{
                alert("TradeYa Verification Code is not valid!");
                $('#verification_code').focus();
            }
        }
    });
}

function remove_number_verification(pnum){
    jQuery.ajax({
        type: "POST",
        url: "/remove_number_verification",
        data: "phone_number=" + pnum, //+ "&authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()),
        success: function(msg, status, xhr){
            if(msg == "success"){
                $(".ph_no_remove").hide();
                $(".pin_resend").hide();
                $(".ph_verify_submit").hide();
                $(".confirm_box").hide();
                $('#phone_number').val("");
                $("p.c_input span.ph_verify").show();
                $("#remove_ph_no").modal("hide");
                alert("Verified phone number has been removed from your profile now.");
            }
        },
        error: function(xhr, status){
        }
    });
    return false;
}

function remove_verification(id){
    jQuery.ajax({
        type: "POST",
        url: "/remove_verification",
        data: "provider=" + id,
        success: function(msg, status, xhr){
            if(msg == "success"){
                document.location.reload();
            }
        },
        error: function(xhr, status){
        }
    });
    return false;
}
function cancelVerification(){
    $('#phone_number').val('+1');
    $('#verification_code').val('');
    $('.verification_sms_call').hide();
    $('.add_more_verification').hide();
    $('.verification_phone_call').hide();
    $('#verification_code_phone').text('');
    return false;
}
