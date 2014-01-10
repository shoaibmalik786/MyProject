// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery.tokeninput
//= require jquery_ujs
//= require jquery.remotipart
//= require jquery-fileupload/basic
//= require twitter/bootstrap
//= require_tree .
//= require wiselinks

$(document).ready(function() {
    window.wiselinks = new Wiselinks($('#tab-content'), { html4_normalize_path: false })
    // window.wiselinks = new Wiselinks("#tab-content");
    // $(document).off('page:loading').on('page:loading', function(event, url, target, render) {
    // return console.log("Wiselinks loading: " + url + " to " + target + " within '" + render + "'");
    // });
    $(document).off('page:complete').on('page:complete', function(event, xhr, settings) {
      return console.log("Wiselinks page loading completed");
    });
    $(document).off('page:success').on('page:success', function(event, $target, status) {
      return console.log("Wiselinks status: '" + status + "'");
    });
    return $(document).off('page:error').on('page:error', function(event, data, status) {
      return console.log("Wiselinks status: '" + status + "'");
    });
    $('input, textarea').placeholder();

});


var isSubmitTradeya = false;
var isSubmitOffer = false;
var isSubmitTradeyaPg = false;
var isPromoteTradeya = false;
var showOnboarding = false;
var isContest = false;
var isAddShowComment = 0; // 1 for add 2 for show 0 for nothing
var unsubscribe_mail = false;
var cat_drpdown_analytics = {4: ['Global Top Nav Browse arts collectibles antiques', 'Clk_NavBrowseArts'], 5: ['Global Top Nav Browse clothing jewelry  accessories', 'Clk_NavBrowseClothes'],6: ['Global Top Nav Browse electronics devices', 'Clk_NavBrowseElectronics'],7: ['Global Top Nav Browse general misc goods', 'Clk_NavBrowseGenGoods'],8: ['Global Top Nav Browse household garden', 'Clk_NavBrowseHousehold'],9: ['Global Top Nav Browse housing vacation spots', 'Clk_NavBrowseHousing'],10: ['Global Top Nav Browse media entertainment', 'Clk_NavBrowseMedia'],11: ['Global Top Nav Browse office photo  music gear', 'Clk_NavBrowseOfficePhotos'],12: ['Global Top Nav Browse sporting goods', 'Clk_NavBrowseSporting'],13: ['Global Top Nav Browse tickets coupons', 'Clk_NavBrowseTickets'],14: ['Global Top Nav Browse vehicles parts', 'Clk_NavBrowseVehicles'],15: ['Global Top Nav Browse accounting finance legal', 'Clk_NavBrowseAccounting'],16: ['Global Top Nav Browse architecture engineering', 'Clk_NavBrowseArchitecture'],17: ['Global Top Nav Browse art, media web design', 'Clk_NavBrowseArtMedia'],18: ['Global Top Nav Browse beauty, fitness health', 'Clk_NavBrowseBeauty'],19: ['Global Top Nav Browse business consulting office', 'Clk_NavBrowseBusiness'],20: ['Global Top Nav Browse coaches healers therapists', 'Clk_NavBrowseCoaches'],21: ['Global Top Nav Browse dental legal medical', 'Clk_NavBrowseMedical'],22: ['Global Top Nav Browse education tutoring', 'Clk_NavBrowseEducation'],23: ['Global Top Nav Browse food nutrition', 'Clk_NavBrowseFood'],24: ['Global Top Nav Browse general misc services', 'Clk_NavBrowseGenServices'],25: ['Global Top Nav Browse programmers developers', 'Clk_NavBrowseProgrammers'],26: ['Global Top Nav Browse vehicle repair maintenance', 'Clk_NavBrowseVehicleRepair']};
var edit_item = 0;

var isStopCarousal = {};
var topCarousalCounter = 0;
var isPageActive = true;
var isWelcomeToTradeyaShow = false;
var ados = ados || {};
ados.run = ados.run || [];
var KM_SignedIn = false;
var isGuest = false;
var isModalVisible = false;
var isQuiz = false;
var isQuizSignUp = false;
var isUserLike = false;
var isUserFollow = false;
var isUserComment = false;
var isUserHaves = false;
var isUserWants = false;
var isLandingPage = false;

// Top Carousel
function slidesTradeyablock(){
    $('#tradeyacarousel').slides({
        counter: ++topCarousalCounter,
        play: 10000,
        pause: 10000,
        hoverPause: true,
        start: 1,
        slideSpeed: 500,
        effect: 'fade',
        generatePagination: false,
        animationComplete: function(current) {
            if(this.counter < topCarousalCounter) {this.stop(); return;}
            jQuery(".tl_current").removeClass("tl_current");
            jQuery("#tl" + current).addClass("tl_current");
            $("div#tradeyacarousel a").flowplayer().each(function() {this.stop();});
        }
    });
}

// Bottom Carousel
function slidesRecentTradeya(){
    $('#recentTradeya').slides({
        play: 10000,
        pause: 10000,
        hoverPause: true,
        start: 1,
        slideSpeed: 500,
        effect: 'fade',
        generatePagination: false,
        animationComplete: function(current) {
            $("div#recentTradeya a").flowplayer().each(function() {this.stop();});
        }
    });
}

// Tradeya By Category Caraousel
function slidesCategoryTradeya(){
    $('#categoryTradeya').slides({
        play: 10000,
        pause: 10000,
        hoverPause: true,
        start: 1,
        slideSpeed: 500,
        effect: 'fade',
        generatePagination: false,
        animationComplete: function(current) {
            $("div#categoryTradeya a").flowplayer().each(function() {this.stop();});
        }
    });
}
function slidesHelloCarousel(){
    $('#helloCarousel').slides({
        play: 5000,
        pause: 5000,
        hoverPause: true,
        start: 1,
        slideSpeed: 500,
        effect: 'fade',
        generatePagination: false,
    });
}

var carousel_cat_id = 0;
// Right CarouselDropdown
function currentTradeyaCaraouselNavigation(option){
    $('#featured_drpdwn').toggleClass('hidedrop');
    $navigation = $('ul.pagination > li.featured');
    $navigation_img = $navigation.children("img");

    carousel_cat_id = option;
    refreshModal('tradeya_carousel_n_r_panel', false);
    return false;
}

function slideCompletedTrade(index,slideCount){
    $('#completed_carousal_' + index).slides({
        play: 5000,
        pause: 1000,
        hoverPause: true,
        start: 1,
        slideSpeed: 500,
        effect: 'fade',
        generatePagination: false,
        next: 'nxt_'+index,
        prev: 'prv_'+index,
        animationComplete: function(current) {
            if(current  == slideCount){
            }
        }
    });
}

function mutualConnectionCarousel(id){
    if(jQuery("#gallery_" + id).length){
        // Declare variables
        var totalImages = jQuery("#gallery_" + id + " > li").length,
        imageWidth = jQuery("#gallery_"+id+" > li:first").outerWidth(true),
        totalWidth = imageWidth * totalImages,
        visibleImages = Math.round(jQuery("#gallery-wrap_"+id).width() / imageWidth),
        visibleWidth = visibleImages * imageWidth;
        var stopPosition = (visibleWidth - totalWidth);

        jQuery("#gallery_"+id).width(totalWidth);

        jQuery("#gallery-prev_"+id).click(function(){
            if(jQuery("#gallery_"+id).position().left < 0 && !jQuery("#gallery_"+id).is(":animated")){
                jQuery("#gallery_"+id).animate({left : "+=" + imageWidth + "px"});
                showScroll("next",id);
            }
            if (jQuery("#gallery_"+id).position().left >= 0)
                hideScroll("prev",id);
            return false;
        });

        jQuery("#gallery-next_"+id).click(function(){
            if(jQuery("#gallery_"+id).position().left > stopPosition && !jQuery("#gallery_"+id).is(":animated")){
                jQuery("#gallery_"+id).animate({left : "-=" + imageWidth + "px"});
                showScroll("prev",id);
            }
            if (jQuery("#gallery_"+id).position().left <= stopPosition)
                hideScroll("next",id);
            return false;
        });
        function showScroll(direction,id)
        {
            jQuery("#gallery-"+direction+"_"+id).show();
            jQuery("#gallery-"+direction+"-grey_"+id).hide();
        }
        function hideScroll(direction,id)
        {
            jQuery("#gallery-"+direction+"-grey_"+id).show();
            jQuery("#gallery-"+direction+"_"+id).hide();
        }
    }
}

function facebook_name_tooltip_show(id1, name, id){
    $("#facebook_name_1_span_"+id).text(name);
    $("#facebook_hide_"+id).show();
    ol = $(id1).offset().left;
    $("#facebook_hide_"+id).css('left', ol + 'px');
}
function facebook_name_tooltip_hide(id1, id){
    $("#facebook_hide_"+id).hide();
}

// Current Offers
function currentOffers(){
    if ($("#current_offer").hasClass('hidedrop')){
        $("#current_offer").removeClass('hidedrop');
        $("#offers_section_current img").attr('src','https://s3.amazonaws.com/tradeya_prod/tradeya/images/arrow_open.png');
        $('#confrm_select_div').show();
    }else{
        $("#current_offer").addClass('hidedrop');
        $("#offers_section_current img").attr('src','https://s3.amazonaws.com/tradeya_prod/tradeya/images/arrow_close.png');
        $('#confrm_select_div').hide();
    }

}

// Comments Section
function commentSection(){
    if ($("#comments_table").hasClass('hidedrop')){
        $("#comments_table").removeClass('hidedrop');
        $("#comments_heading img").attr('src','https://s3.amazonaws.com/tradeya_prod/tradeya/images/arrow_open.png');
    }else{
        $("#comments_table").addClass('hidedrop');
        $("#comments_heading img").attr('src','https://s3.amazonaws.com/tradeya_prod/tradeya/images/arrow_close.png');
    }

}

function privateSection(trade_id){
    if ($("#private_comments_table_"+trade_id).hasClass('hidedrop')){
        $("#private_comments_table_" + trade_id).removeClass('hidedrop');
        $('#hide_conversation_'+trade_id).text('Hide Conversation Thread');
    }else{
        $("#private_comments_table_"+trade_id).addClass('hidedrop');
        $('#hide_conversation_'+trade_id).text('Show Conversation Thread');
    }

}

// Have and Want Links
function haveLink(){
    $("#have_anchor img").attr('src','https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/have_selected_new.png');
    $(".user_has").show();
    $(".user_wants").hide();
    $("#want_anchor img").attr('src','https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/want_new.png');
    $("#head_bar img").attr('src','https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/bar1.png');
    $("#add_item_table").hide();

    return false;
}
// function nextButton(){
function submitTradeyaFormChk()
{
    // if(!canSubmitCanNext) return;
    var chk = true;
    var qty = $('#item_quantity').val();
    $("#photomessage").text("");
    $("#titlemessage").text("");
    $("#descmessage").text("");
    $("#qntymessage").text("");
    $("#condmessage").text("");
    if($('#choose_cat').text() == 'Choose a category'){
        $("#category_error").text("Category cannot be left blank");
        chk = false;

    }else if($('#item_title').val() == '' || $('#item_title').val() == 'Write a title for your good or service here...'){
        $("#titlemessage").show();
        $("#descmessage").hide();
        $("#qntymessage").hide();
        $("#condmessage").hide();
        $("#titlemessage").text("Item Title cannot be left blank ");
        chk = false;
    }else if ( !($('#item_condition_1').is(':checked')) && !($('#item_condition_2').is(':checked')) && ($("#item_category_id").attr("cat_p_name") != "Services") && ($("#item_category_id").attr("cat_p_name") != "Housing")){
        $("#condmessage").show();
        $("#titlemessage").hide();
        $("#descmessage").hide();
        $("#qntymessage").hide();

        $("#condmessage").text("Item Condition cannot be left blank ");
        chk = false;
    }else if ( qty <= '0' ){
        $("#qntymessage").show();
        $("#titlemessage").hide();
        $("#descmessage").hide();
        $("#condmessage").hide();
        $("#qntymessage").text("Please enter a valid quantity");
        chk = false;
    }else if($('#item_desc').val() == '' || $('#item_desc').val() == 'Add more details about your good or service here...'){
        $("#descmessage").show();
        $("#titlemessage").hide();
        $("#qntymessage").hide();
        $("#condmessage").hide();
        $("#descmessage").text("Item Description cannot be left blank ");
        chk = false;
        // }else if($("#item_photos").val().length <= 0 && $("#item_videos").val().length <= 0)
        // {
        //      $("#photomessagempty").text("Item Photo/Video/Recording cannot be left blank");
        //      chk = false;
    }else if(!$("#item_qty_unlimited").is(":checked"))
    {
        if($("#item_quantity").val() == '' || $("#item_quantity").val() <= 0)
            chk = false;
        if($("#item_quantity").val().length > 0){
            var intRegex = /^\d+$/;
            if (!intRegex.test($("#item_quantity").val()))
                chk = false;
        }
        if(!chk)
            $("#qntymessage").text("Please enter a valid quantity");
    }

    // }
    // else if(($('#selected_photo_file').text() == "No file selected" || $('#selected_photo_file').text() == "") && ($('#selected_video_file').text() == "No file selected" || $('#selected_video_file').text() == "") && jQuery('#item_item_photo_photo').val() == '' && jQuery('#item_item_video_video').val() == '' && jQuery('input:radio[name=archive_id]:checked').val() == undefined){
    //  $("#photomessage").text("Item Photo/Video/Recording cannot be left blank");
    //  $("#titlemessage").text("");
    //  $("#categorymessage").text("");
    //  $("#descmessage").text("");
    // }else if(isCropping){
    //  alert('Please click "Submit" to crop, or "Delete this photo" link.');
    if(chk)
    {
        jQuery.ajax({
            url: "/is_signed_in",
            success: function(data){
                if(data == "true"){
                    mixpanel.track('Click Submit on Add Item Page');
                    // _gaq.push(['_trackEvent', 'Add Item', 'Clk_Sbmt', 'Click Submit Item on Add Item Page']);
                    submitItemForm();
                }else{
                    // _kmq.push(['record', 'Login', {'Show Login Modal': 'submit tradeya', 'SignedIn' : get_KMSignedIn()}]);
                    isSubmitTradeya = true;
                    openLoginForm();
                }
            }
        });


        // $("body, html").scrollTop(0);
        // $("#titlemessage").text("");
        // $("#categorymessage").text("");
        // $("#descmessage").text("");
        // $("#photomessage").text("");
        // $(".user_has").hide();
        // $(".user_hasie").hide();
        // $(".user_wantsie").show();
        // $(".user_wants").show();
        // $("#have_anchor img").attr('src','https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/have_new.png');
        // $("#want_anchor img").attr('src','https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/want_selected_new.png');
        // $("#head_bar img").attr('src','https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/bar2.png');
        // $("#add_item_table").show();
        // _kmq.push(['record', 'Submit TradeYa Page Main Next Button',{ 'SignedIn' : get_KMSignedIn()}]);
        // _gaq.push(['_trackEvent', 'Activity', 'Clk_NxtBtn', 'Click Next for Submitting TradeYa']);

    }
    return false;
}

// Category DropDowns
function selectCategory(li, choose_cat_id, drop_id, form_name, cat_id){
    var good = $(li).attr("v");
    $("#" + choose_cat_id).text(good);
    $('.subcategories').addClass('hidedrop');
    $('#' + drop_id).addClass('hidedrop');
    $('#' + form_name + '_category_id').attr('value', cat_id);
    $('#' + form_name + '_category_id').attr('cat_name', $(li).attr("cat_name"));
    $('#' + form_name + '_category_id').attr('cat_p_name', $(li).attr("cat_p_name"));
}
// State Dropdown
function selectState(li){
    var state = $(li).text();
    $('.edit_state').text(state);
    $('#profile_states').addClass('hidedrop');
    $('#user_state').attr('value',state);
}
// State Dropdown1
function selectExchangeState1(li){
    var state = $(li).text();
    $('.exchange_state').text(state);
    $('#exchange_state_drp1').addClass('hidedrop');
    $('#addresses_state').attr('value',state);
}
// State Dropdown2
function selectExchangeState2(li){
    var state = $(li).text();
    $('.exchange_state').text(state);
    $('#exchange_state_drp2').addClass('hidedrop');
    $('#addresses_state').attr('value',state);
}
// Video/Image Tabs
function tab1a(){
    $("#tab2 a").removeClass('current');
    $("#tab1 a").addClass('current');
    $(".pane1").css('display','block');
    $(".pane2").css('display','none');
    return false;
}
function tab2a(){
    $("#tab1 a").removeClass('current');
    $("#tab2 a").addClass('current');
    $(".pane1").css('display','none');
    $(".pane2").css('display','block');
    if(!isRecorderInit) init();
    return false;
}
// Multiple category Dropdown
// function selectMultipleCategory_old(li, item_id, cat_id, sel_cats){
//      if(!$(li).hasClass('categoryselected')){
//              $(li).addClass("categoryselected");
//              cat = $(li).attr("v");
//              $("#category_selected").append("<li onclick='removeCategory(this,\"" + item_id + "\", " + cat_id + ", \"" + sel_cats + "\");'>"+ cat +"</li>");
//              $('.subcategories').addClass('hidedrop');
//              $('#category_drop_offer').addClass('hidedrop');
//              var val = $('#item_' + sel_cats).attr('value');
//              $('#item_' + sel_cats).attr('value', ((val.length == 0) ? cat_id : val + ',' + cat_id));
//
//      }
// }
// function removeCategory_old(id, cat, cat_id, sel_cats){
//      $(id).remove();
//      $('#' + cat).removeClass("categoryselected");
//      var cats = $('#item_' + sel_cats).attr('value').split(',');
//      $('#item_' + sel_cats).attr('value', '');
//      for(var i = 0; i < cats.length; i++){
//              var val = $('#item_' + sel_cats).attr('value');
//              if(cats[i] != cat_id) $('#item_' + sel_cats).attr('value', ((val.length == 0) ? cats[i] : val + ',' + cats[i]));
//      }
//
// }

// Multiple category Dropdown
function selectMultipleCategory(li, item_id, cat_id, sel_cats, display_div,remove_from_list,onclick_calls){
    if (typeof(remove_from_list) == 'undefined') { remove_from_list = false;}
    if(typeof(onclick_calls) == 'undefined') { onclick_calls=""}
    if(!$(li).hasClass('categoryselected')){
        $(li).addClass("categoryselected");
        if (remove_from_list)
        {
            $(li).addClass('hidedrop');
        }
        cat = $(li).attr("v");
        $('#' + display_div).append("<li onclick=\" removeCategory(this,'" + item_id + "', " + cat_id + ", '" + sel_cats + "'," + remove_from_list + ");" + onclick_calls +"\">"+ cat +"</li>");
        $('.subcategories').addClass('hidedrop');
        $('#category_drop_offer').addClass('hidedrop');
        var val = $('#' + sel_cats).attr('value');
        $('#' + sel_cats).attr('value', ((val.length == 0) ? cat_id : val + ',' + cat_id));

    }
}
function removeCategory(id, cat, cat_id, sel_cats,remove_from_list){
    if (typeof(remove_from_list) == 'undefined') { remove_from_list = false;}
    $(id).remove();
    $('#' + cat).removeClass("categoryselected");
    if(remove_from_list)
    { $('#' + cat).removeClass("hidedrop"); }
    var cats = $('#' + sel_cats).attr('value').split(',');
    $('#' + sel_cats).attr('value', '');
    for(var i = 0; i < cats.length; i++){
        var val = $('#' + sel_cats).attr('value');
        if(cats[i] != cat_id) $('#' + sel_cats).attr('value', ((val.length == 0) ? cats[i] : val + ',' + cats[i]));
    }

}
// Clearing textfields onclick
function clearText(field){
    if(field.id == 'contact_re'){
        if (contact_re_default_val == field.value) field.value = '';
        else if (field.value == '') field.value = contact_re_default_val;
    }if(field.id == 'input_comment'){
        if($('#input_comment').is(":focus") && field.defaultValue == field.value) field.value = '';
        else if (field.value == '') field.value = field.defaultValue;
    }else{
        if (field.defaultValue == field.value) field.value = '';
        else if (field.value == '') field.value = field.defaultValue;
    }
}
isImageUploading = false;
function imagePreview(f, form_id, img_prev_id, item, itemPhotoId, imageURL){
    if(isImageUploading) return;
    isImageUploading = true;
    canSubmitCanNext = false;
    // if($('#' + f).val() != '')
    // {
    jQuery('#image_spinner').show();
    if (jQuery('#profile_spinner').length > 0 ) { jQuery('#profile_spinner').show(); }
    jQuery('#ind_' + img_prev_id).show();
    if(document.getElementById('ind_' + img_prev_id))document.getElementById('ind_' + img_prev_id).style.display = 'block';
    $("#tab1 a").text('Photo or Video preview');

    var fld_id = f;
    var f = jQuery('#' + form_id);
    var tAction = f.attr('action');
    var have_target = f.attr('target') == 'if_ip_upload' ? true : false;
    if(!have_target)f.attr('target', 'if_ip_upload');
    f.attr('action', '/image_preview?img_prev_id=' + img_prev_id + '&itemimg=' + item + "&fld_id=" + fld_id + "&item_photo_id=" + itemPhotoId + "&form_id=" + form_id + ((typeof(imageURL) != 'undefined')? "&imageURL=" + encodeURIComponent(imageURL) : ""));
    f.submit();
    if(!have_target)f.removeAttr('target');
    f.attr('action', tAction);
    stopSpinner();
    //}
}

function videoPreview(f, form_id, img_prev_id, itemVideoId){
    canSubmitCanNext = false;
    jQuery('#video_spinner').show();
    jQuery('#ind_' + img_prev_id).show();
    document.getElementById('ind_' + img_prev_id).style.display = 'block';

    var fld_id = f;
    var f = jQuery('#' + form_id);
    var tAction = f.attr('action');
    var have_target = f.attr('target') == 'if_ip_upload' ? true : false;
    if(!have_target)f.attr('target', 'if_ip_upload');
    f.attr('action', '/video_preview?img_prev_id=' + img_prev_id + "&fld_id=" + fld_id + "&item_video_id=" + itemVideoId);
    f.submit();
    if(!have_target)f.removeAttr('target');
    f.attr('action', tAction);
    stopSpinner();
}

function resetPhotoModal()
{
    $('#step2_web').hide();
    $('#item_photo_url').val("http://")
    $('#step2_computer').hide();
}

function resetItemWantFields(){
    jQuery('#item_item_want_title')[0].value = jQuery('#item_item_want_title')[0].defaultValue;
    jQuery('#item_item_want_category_id').val('');
    jQuery('#choose_cat_want').text('Choose a category');
    jQuery('#item_item_want_desc')[0].value = jQuery('#item_item_want_desc')[0].defaultValue;
}

// Your offer Video/Image Tabs
function tabofferSelect(){
    $(".pane1_offer").css('display','block');
    $(".pane2_offer").css('display','none');
    $("#tab1_offer a").addClass('current');
    $("#tab1_offer a").click(function(){
        $("#tab2_offer a").removeClass('current');
        $("#tab1_offer a").addClass('current');
        $(".pane1_offer").css('display','block');
        $(".pane2_offer").css('display','none');
    });
    $("#tab2_offer a").click(function(){
        $("#tab1_offer a").removeClass('current');
        $("#tab2_offer a").addClass('current');
        $(".pane1_offer").css('display','none');
        $(".pane2_offer").css('display','block');
    });
}

//Checkboxes
function checkUncheck(chk, anotherChkId, formChkId,anotherFormChkId){
    $("#opencatmessage").text("");
    var oChk = document.getElementById(formChkId);
    var anotherChk = document.getElementById(anotherFormChkId);
    if(oChk){
        oChk.checked = !oChk.checked;
    }
    $(chk).attr('src', (oChk.checked) ? "https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/checkbox_filled.png" : "https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/checkbox.png");
    if (anotherChk){
        if (oChk.checked) { anotherChk.checked = false;}
        $('#' + anotherChkId).attr('src', (anotherChk.checked) ? "https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/checkbox_filled.png" : "https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/checkbox.png");
    }
    if(anotherChkId == 'checkAllOffers' && oChk.checked){
        jQuery('#div_open_cats').show();
    }else{
        jQuery('#div_open_cats').hide();
    }

}

function checkUncheckMult(chk, anotherChkId, formChkId){
    var oChk = document.getElementById(formChkId);
    if(oChk){
        oChk.checked = !oChk.checked;
    }
    if(anotherChkId == 'checkspoffers'){
        $(chk).attr('src', (oChk.checked) ? "https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/checkbox.png" : "https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/checkbox_filled.png");
        $('#' + anotherChkId).attr('src', (oChk.checked) ? "https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/checkbox_filled.png" : "https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/checkbox.png");
    }else{
        $(chk).attr('src', (oChk.checked) ? "https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/checkbox_filled.png" : "https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/checkbox.png");
        $('#' + anotherChkId).attr('src', (oChk.checked) ? "https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/checkbox.png" : "https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/checkbox_filled.png");
    }

}

function addAnotherItemWant(){
    $("#descwantmessage").text("");
    $("#titlewantmessage").text("");
    $("#categorywantmessage").text("");
    $("#opencatmessage").text("");
    $('#error_message_top_wants').hide();
    if(jQuery('#item_item_want_title').val() == '' || jQuery('#item_item_want_title').val() == 'Write a title for what you want here...'){
        $("#titlewantmessage").text("Item Title cannot be left blank ");
        $("#descwantmessage").text("");
        $("#categorywantmessage").text("");
    }else if(jQuery('#item_item_want_category_id').val() == ''){
        $("#categorywantmessage").text("Item Category cannot be left blank ");
        $("#titlewantmessage").text("");
        $("#descwantmessage").text("");
    }else if(jQuery('#item_item_want_desc').val() == '' || jQuery('#item_item_want_desc').val() == 'Add details about what you want here...'){
        $("#descwantmessage").text("Item Description cannot be left blank ");
        $("#titlewantmessage").text("");
        $("#categorywantmessage").text("");
    }else{
        if($("#edit_item_flag").val() == "true"){
            var i = $("#edit_item_want_index").val();
            var item = parseInt(i) + 1;
            item_wants[i][0] = $('#item_item_want_title').attr('value');
            item_wants[i][1] = $('#item_item_want_category_id').attr('value');
            item_wants[i][2] = $('#item_item_want_desc').attr('value');
            item_wants[i][4] = $('#item_item_want_category_id').attr('cat_name');
            item_wants[i][5] = $('#item_item_want_category_id').attr('cat_p_name');
            $("#item_want_" + item).show();
            $('#item_' + item).empty();
            $('#item_' + item).append('<div class="item_want_title">' + item_wants[i][0] + "</div>");
            $('#item_' + item).append('<div class="item_want_category">' + item_wants[i][5] + ': ' + item_wants[i][4] + "</div>");
            $('#item_' + item).append('<div class="item_want_desc">' + item_wants[i][2] + "</div>");
            $("#edit_item_want_index").val('');
            $("#edit_item_flag").val("false");
            $('#item_want_number').text('Item No. ' + (item_wants.length + 1));
        }else{
            var iw = [];
            iw[0] = $('#item_item_want_title').attr('value');
            iw[1] = $('#item_item_want_category_id').attr('value');
            iw[2] = $('#item_item_want_desc').attr('value');
            iw[3] = ++item_wants_count;
            iw[4] = $('#item_item_want_category_id').attr('cat_name');
            iw[5] = $('#item_item_want_category_id').attr('cat_p_name');

            item_wants.push(iw);

            $('#add_item_table').append('<tr id="item_want_' + item_wants_count + '" valign="top"></tr>');
            $('#item_want_' + item_wants_count).append('<td id="item_delete_' + item_wants_count + '" class="item_number_total" width="15%"><div id="item_number_count_text_' + (item_wants_count) +'">Item No. ' + (item_wants_count) + "</div></td>");
            $('#item_delete_' + item_wants_count).append('<div class="delete_item"><a href="#" onclick="return removeAnotherItemWant(\'item_want_' + item_wants_count + '\', ' + item_wants_count + ')">delete'+"</a></div>");
            $('#item_delete_' + item_wants_count).append('<div class="delete_item" style="margin-top: 5px;"><a href="#" onclick="return editItemWant(' + item_wants_count + ')">Edit'+"</a></div>");
            $('#item_want_' + item_wants_count).append('<td width="3%"></td>');
            $('#item_want_' + item_wants_count).append('<td id="item_td_' + item_wants_count + '"></td>');
            $('#item_td_' + item_wants_count).append('<div id="item_' + item_wants_count + '" class="itemdiv"></div>');
            $('#item_' + item_wants_count).append('<div class="item_want_title">' + iw[0] + "</div>");
            $('#item_' + item_wants_count).append('<div class="item_want_category">' + $('#item_item_want_category_id').attr('cat_p_name') + ': ' + $('#item_item_want_category_id').attr('cat_name') + "</div>");
            $('#item_' + item_wants_count).append('<div class="item_want_desc">' + iw[2] + "</div>");
            $('#item_want_number').text('Item No. ' + (item_wants_count + 1));
        }

        resetItemWantFields();

    }
}

function removeAnotherItemWant(view_id, data_index){
    jQuery('#' + view_id).remove();
    var index = -1;
    for(i = 0; i < item_wants.length; i++){
        if(item_wants[i][3] == data_index){ index = i; break;}
    }
    if(index >= 0){
        item_wants.splice(index, 1);
        for(i = data_index + 1,j = data_index,k = data_index - 1;i <= item_wants_count; i++,j++,k++){
            $('#item_want_' + i).empty();
            $('#item_want_' + i).attr('id','item_want_' + j);
            $('#item_want_' + j).append('<td id="item_delete_' + j + '" class="item_number_total" width="15%"><div id="item_number_count_text_' + (j) +'">Item No. ' + (j) + "</div></td>");
            $('#item_delete_' + j).append('<div class="delete_item"><a href="#" onclick="return removeAnotherItemWant(\'item_want_' + j + '\', ' + j + ')">delete'+"</a></div>");
            $('#item_delete_' + j).append('<div class="delete_item" style="margin-top: 5px;"><a href="#" onclick="return editItemWant(' + j + ')">Edit'+"</a></div>");
            $('#item_want_' + j).append('<td width="3%"></td>');
            $('#item_want_' + j).append('<td id="item_td_' + j + '"></td>');
            $('#item_td_' + j).append('<div id="item_' + j + '" class="itemdiv"></div>');
            $('#item_' + j).append('<div class="item_want_title">' + item_wants[k][0] + "</div>");
            $('#item_' + j).append('<div class="item_want_category">' + item_wants[k][5] + ' - ' + item_wants[k][4] + "</div>");
            $('#item_' + j).append('<div class="item_want_desc">' + item_wants[k][2] + "</div>");
        }
        item_wants_count--;
        for(i = index;i<item_wants.length;i++){
            item_wants[i][3] = item_wants[i][3] - 1;
        }
        //for adjusting item number count
        for(var i = 1;i<=item_wants.length;i++){
            $("#item_number_count_text_" + (i)).text('Item No. ' + (i));
        }
        $('#item_want_number').text('Item No. ' + (item_wants.length + 1));
    }


    return false;
}

function editItemWant(index){
    index = index - 1;
    $("#item_want_" + (index + 1)).hide();
    $("#edit_item_want_index").val(index);
    $("#edit_item_flag").val("true");
    $('#item_want_number').text('Item No. ' + (index + 1));
    $('#item_item_want_title').val(item_wants[index][0]);
    $('#choose_cat_want').val(item_wants[index][4]);
    $('#choose_cat_want').text(item_wants[index][4]);
    $('#item_item_want_desc').val(item_wants[index][2]);
    $('#item_item_want_category_id').val(item_wants[index][1]);
    $('#item_item_want_category_id').attr('cat_name', item_wants[index][4]);
    $('#item_item_want_category_id').attr('cat_p_name', item_wants[index][5]);
}

function alternate(id){
    if(document.getElementsByTagName){
        var table = document.getElementById(id);
        var rows = table.getElementsByTagName("tr");
        for(i = 0; i < rows.length; i++){
            if(i % 2 == 0){
                rows[i].className = "even";
            }else{
                rows[i].className = "odd";
            }
        }
    }
}

function showOfferForm(){
    isCancelSubmitOffer = false;

    $('#your_offer_form_div').show();
    $('.makeoffer_btn').hide();
    $('.makeofferclicked_btn').show();
    $('#spambot_div').html('<input type="checkbox" id="spambot" name="captcha" style="display:none" value="1" />');
    customScroll("#your_offer_form_div");
    // window.location = '#your_offer_form_div';


    return false;
}

function submitOfferChkSignIn(){
    if(!canSubmitCanNext) return;
    var chk = true;
    $("#photomessage").text("");
    $("#titlemessage").text("");
    $("#descmessage").text("");
    //$("#qntymessage").text("");
    if($('#item_title').val() == '' || $('#item_title').val() == 'Write a title for your good or service here...'){
        $("#titlemessage").text("Item Title cannot be left blank ");
        chk = false;
    }else if($('#item_desc').val() == '' || $('#item_desc').val() == 'Add more details about your good or service here...'){
        $("#descmessage").text("Item Description cannot be left blank ");
        chk = false;
        // }else if($("#item_photos").val().length <= 0 && $("#item_videos").val().length <= 0)
        // {
        //      $("#photomessage").text("Item Photo/Video/Recording cannot be left blank");
        //      chk = false;
        // }else if(!$("#item_qty_unlimited").is(":checked")){
        //      if($("#item_quantity").val() == '' || $("#item_quantity").val() <= 0)
        //              chk = false;
        //      if($("#item_quantity").val().length > 0){
        //              var intRegex = /^\d+$/;
        //              if (!intRegex.test($("#item_quantity").val()))
        //                      chk = false;
        //      }
        //      if(!chk)
        //              $("#qntymessage").text("Please enter a valid quantity");
    }
    // if(!canSubmitCanNext) return;
    // offerForm = ((ignore_imgChk == true)?'new' : 'old');
    // if(jQuery('#item_title').val() == '' || jQuery('#item_title').val() == 'Write a title for your good or service here...'){
    //  $("#titlemessage").text("Item Title cannot be left blank ");
    //  $("#categorymessage").text("");
    //  $("#descmessage").text("");
    //  $("#photomessage").text("");
    // }else if(jQuery('#item_category_id').val() == ''){
    //  $("#categorymessage").text("Item Category cannot be left blank ");
    //  $("#descmessage").text("");
    //  $("#titlemessage").text("");
    //  $("#photomessage").text("");
    // // }else if(jQuery('#item_desc').val() == '' || jQuery('#item_desc').val() == 'Add more details about your good or service here...'){
    // //       $("#descmessage").text("Item Description cannot be left blank ");
    // //       $("#categorymessage").text("");
    // //       $("#titlemessage").text("");
    // //       $("#photomessage").text("");
    // }else if((jQuery('#selected_photo_file').text() == "No file selected" || jQuery('#selected_photo_file').text() == "") && (jQuery('#selected_video_file').text() == "No file selected" || jQuery('#selected_video_file').text() == "") && jQuery('#item_item_photo_photo').val() == '' && jQuery('#item_item_video_video').val() == '' && jQuery('input:radio[name=archive_id]:checked').val() == undefined && (typeof(ignore_imgChk)=='undefined' || ignore_imgChk != true)){
    //  $("#photomessage").text("Item Photo/Video/Recording cannot be left blank");
    //  $("#descmessage").text("");
    //  $("#categorymessage").text("");
    //  $("#titlemessage").text("");
    // }else if(isCropping){
    //  alert('Please click "Submit" to crop, or "Delete this photo" link.');
    // }else if(!$('#spambot').is(':checked')){
    //  alert('Please check spambot check box');
    // }else{
    if(chk)
    {
        if(!$('#spambot').is(':checked'))
            alert('Please check spambot check box');
        else
        {
            jQuery.ajax({
                url: "/is_signed_in",
                success: function(data){
                    if(data == "true"){
                        // _kmq.push(['record', 'TradeYa Page Sumbit Offer Button', {'SignedIn' : get_KMSignedIn()}]);
                        // _gaq.push(['_trackEvent', 'Activity', 'Clk_SbmOfr', 'Click Submit Offer Link']);
                        submitItemForm();
                    }else{
                        // _kmq.push(['record', 'Login', {'Show Login Modal':'make an offer', 'SignedIn' : get_KMSignedIn()}]);
                        isSubmitOffer = true;
                        // showModal('login_box');
                        openLoginForm();
                    }
                }
            });
        }
    }
}

function submitItemForm(){
    if(!canSubmitCanNext) return;
    canSubmitCanNext = false;
    startSpinner();
    setTimeout(function() {jQuery('#item_form').submit();}, 500);
}

var item_id = 0;
var input_comment_val = '';
// function addCommentOnEnter(i, item_id, event, offer_id){
//      if (event.keyCode == 13) {
//              addComment(i, item_id, offer_id);
//     }
// }

function addCommentOnEnter(event,uniq_id,p_tag){
    if (event.keyCode == 13) {
        (event.preventDefault) ? event.preventDefault() : event.returnValue = false;
        addComment(uniq_id,p_tag);
    }
}

// function addComment(i, item_id, offer_id){
//      input_comment_val = jQuery(i).val();
//      if(input_comment_val == 'Write your comment here ...' || input_comment_val.trim() == '') return;
//      $('#comments_spinner').show();
//      jQuery.ajax({
//              type: "POST",
//              url: "/comments",
//              data: "comment[item_id]=" + item_id + "&isDivOpen=true&comment[comment]=" + input_comment_val + "&authenticity_token=" + encodeURIComponent($("#newCommentForm input[name=authenticity_token]").val()) + ((typeof(offer_id) != 'undefined')? "&comment[offer_id]="+offer_id : "" ),
//              success: function(msg, status, xhr){
//                      jQuery("#refresh_modal_div").html(msg);
//                      $('#comments_spinner').hide();
//              },
//              error: function(xhr, status){
//                      $('#comments_spinner').hide();
//              }
//      });
// }

function rejectOffer(trade_id){
    jQuery.ajax({
        type: "POST",
        url: "/trades/" + trade_id + "/reject",
        data: "authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()),
        success: function(msg, status, xhr){
            // jQuery("#refresh_modal_div").html(msg);
        },
        error: function(xhr, status){
        }
    });
}

var KM_user = '';
function sign_in(){
    // _kmq.push(['record', 'Modal Login Primary Login Button',{ 'SignedIn' : get_KMSignedIn()}]);
    // _gaq.push(['_trackEvent', 'register', 'login', 'Login Modal']);
    jQuery('#signinmessage').hide();
    jQuery('#signinmessage').text('');
    var regex ="^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$";
    if(document.getElementById('user_login_email').value == ''){
	jQuery('#signinmessage').show();
        jQuery('#signinmessage').text('Email address cannot be empty');
    }else if (document.getElementById('user_login_email').value.match(regex) == null){
	jQuery('#signinmessage').show();
        jQuery('#signinmessage').text('Email address format not correct');
    }else if (document.getElementById('user_password').value == ''){
	jQuery('#signinmessage').show();
        jQuery('#signinmessage').text('Password Cannot be blank');
    }else{
        jQuery.ajax({
            type: "POST",
            url: "/users/sign_in",
            data: "user[email]=" + jQuery('#user_login_email').val() + "&user[password]=" + jQuery('#user_password').val() + (jQuery('#user_remember_me').is(':checked')? "&user[remember_me]=1" : "") + "&authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()),
            success: function(msg, status, xhr){

                KM_user = jQuery('#user_email').val();
                var obj = jQuery.parseJSON(xhr.responseText);
                if(obj.success && obj.count > 1){
                    window.location = '/items?category=all';
                    analytics.track('Logged in', {'Login method': 'TradeYa'});
                    // _gaq.push(['_trackEvent', 'Email Login', 'Clk_login', 'Successful Login Email']);
                    closeLoginForm();
                }else if(obj.success && obj.count == 1){
                    window.location = '/users/' + obj.id
                    // _gaq.push(['_trackEvent', 'Email Login', 'Clk_login', 'Successful Login Email']);
                    analytics.track('Logged in', {'Login method': 'TradeYa'});
                    closeLoginForm();
                }else if(obj.fb_user){
                    jQuery('#signinmessage').show();
                    jQuery('#signinmessage').text("Looks like you've signed up through facebook. Try the facebook login");
                }else{
                    jQuery('#signinmessage').show();
                    jQuery('#signinmessage').text("Invalid Email or Password");
                }

                // if(msg.indexOf('true:token') > -1){
                //     sign_in_callback(true, "review_token", msg.split(':')[2],msg.split(':')[4]);
                // }else if(msg.indexOf('true:pub') > -1 || (msg.indexOf('true:pub') > -1 && !isSubmitTradeya && !isSubmitOffer)){
                //     sign_in_callback(true, true, msg.split(':')[2],msg.split(':')[4]);
                // }else if(msg.indexOf('true:profile') > -1 ){
                //     sign_in_callback(true,false,0,msg.split(':')[2]);
                // }else{
                //     jQuery('#signinmessage').text(xhr.responseText);
                //     closeLoginForm();
                //     // sign_in_callback(false);
                // }
            },
            error: function(xhr, status){
		jQuery('#signinmessage').show();
                jQuery('#signinmessage').text(xhr.responseText);
                sign_in_callback(false);
            }
        });
    }
}

function request_invite(){
    // _gaq.push(['_trackEvent', 'register', 'login', 'Login Modal']);
    jQuery('#requestmessage').hide();
    jQuery('#requestmessage').text('');
    var regex ="^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$";
    var regex_name = "^([a-zA-Z\s\-]*)$"
    if (document.getElementById('user_first_name').value == ''){
	    jQuery('#requestmessage').show();
        jQuery('#requestmessage').text('Please enter a First Name');
    }else if (document.getElementById('user_first_name').value.match(regex_name) == null){
        jQuery('#requestmessage').show();
        jQuery('#requestmessage').text('First name format not correct');
    }else if(document.getElementById('user_email').value == ''){
	    jQuery('#requestmessage').show();
        jQuery('#requestmessage').text('Email address cannot be empty');
    }else if (document.getElementById('user_email').value.match(regex) == null){
	    jQuery('#requestmessage').show();
        jQuery('#requestmessage').text('Email address format not correct');
    }else if ( !($('#user_gender_male').is(':checked')) && !($('#user_gender_female').is(':checked')) && !($('#user_gender_none').is(':checked')) ){
    jQuery('#requestmessage').show();
        jQuery('#requestmessage').text('Please select a Gender');
    }else{
        jQuery.ajax({
            type: "POST",
            url: "/reinvite",
            data: "user[email]=" + jQuery('#user_email').val() +
                "&user[first_name]=" + jQuery('#user_first_name').val() +
                "&user[gender]=" + jQuery("input:radio:checked").val() +
                "&authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()),
            success: function(data){
                // $('#request_modal').html(data);
                $('#request_content').hide();
                $('#request_thanks').show();
                // closeLoginForm();
            },
            error: function(xhr, status){
                $('#request_content').hide();
                $('#request_thanks').show();
                // $('#request_modal').html(xhr.responseText);
                // jQuery('#requestmessage').text(xhr.responseText);
            }
        });
    }
}

function close_request_modal(){
    $('#requestmessage').hide();
    $('#requestmessage').text('');
    document.getElementById('user_first_name').value = '';
    document.getElementById('user_email').value = '';
    $("#user_gender_none").removeAttr("checked");
    $("#user_gender_male").removeAttr("checked");
    $("#user_gender_female").removeAttr("checked");
    $('#request_thanks').hide();
    $('#request_content').show();
    $("#request_modal").modal("hide");
}

var like_id;
function likeItem(item_id,a_tag){
    jQuery.ajax({
        url: "/is_signed_in",
        success: function(data){
            if(data == "true")
            {
                if(typeof(a_tag) == 'undefined')
                    a_tag = $('#like_'+item_id);
                $(a_tag).parents("#like_action").submit();
                // _kmq.push(['record', 'Like Item',{ 'SignedIn' : get_KMSignedIn()}]);
                // mixpanel.track('click Like on Item card');
                // _gaq.push(['_trackEvent', 'Item Card', 'Clk_ItmLk', 'Click Like on Item Card']);
            }
            else
            {
                if(typeof(a_tag) == 'undefined')
                    a_tag = $('#like_'+item_id);
                $(a_tag).parents("#like_action").removeAttr("data-remote");
                like_id = item_id;
                isUserLike = true;
                openLoginForm();
            }
        }
    });
}

function havesUser(){
    jQuery.ajax({
        url: "/is_signed_in",
        success: function(data){
            if(data == "true")
            {
                $('#haves_action').submit();
                // _kmq.push(['record', 'User Haves',{ 'SignedIn' : get_KMSignedIn()}]);
                mixpanel.track('click Have button on Item');
                // _gaq.push(['_trackEvent', 'Activity', 'Clk_haves', 'Click Haves Button on Item page']);
            }
            else
            {
                $('#haves_action').removeAttr("data-remote");
                isUserHaves = true;
                openLoginForm();
            }
        }
    });
}

var want_id;
function wantsUser(item_id,a_tag){
    jQuery.ajax({
        url: "/is_signed_in",
        success: function(data){
            if(data == "true")
            {
                if(typeof(a_tag) == 'undefined')
                    a_tag = $('#want_'+item_id);
                $(a_tag).parents("#wants_action").submit();
                // _kmq.push(['record', 'User wants',{ 'SignedIn' : get_KMSignedIn()}]);
                // mixpanel.track('click want on Item card');
                // _gaq.push(['_trackEvent', 'Item Card', 'Clk_ItmWnt', 'Click Want on Item card']);
            }
            else
            {
                if(typeof(a_tag) == 'undefined')
                    a_tag = $('#want_'+item_id);
                $(a_tag).parents("#wants_action").removeAttr("data-remote");
                want_id = item_id;
                isUserWants = true;
                openLoginForm();
            }
        }
    });
}
var follow_id;
function followUser(uid,a_tag){
    jQuery.ajax({
        url: "/is_signed_in",
        success: function(data){
            if(data == "true")
            {
                if(typeof(a_tag) == 'undefined')
                    a_tag = $('#follow_'+uid);
                $(a_tag).parents("#follow_action").submit();
                // _kmq.push(['record', 'Follow User',{ 'SignedIn' : get_KMSignedIn()}]);
            }
            else
            {
                if(typeof(a_tag) == 'undefined')
                    a_tag = $('#follow_'+uid);
                $(a_tag).parents("#follow_action").removeAttr("data-remote");
                follow_id = uid;
                isUserFollow = true;
                openLoginForm();
            }
        }
    });
}

var comment_id;
function addComment(id,p){
    if(typeof(p) == 'undefined')
        p = $('#comment_section_p_'+id);
    var form = p.parents('form');
    if(form.find('#comment_box').val() == ""){
        form.find('#error_comment').text('Comment should not be empty');
        return false
    }else{
        jQuery.ajax({
            url: "/is_signed_in",
            success: function(data){
                if(data == "true")
                {
                    form.submit();
                    // $('#comment_action').submit();
                    // _kmq.push(['record', 'Comment on Item',{ 'SignedIn' : get_KMSignedIn()}]);
                    mixpanel.track('Enter comment on Item');
                    // _gaq.push(['_trackEvent', 'Activity', 'enter_comment', 'Enter comment on Item']);
                }
                else
                {
                    comment_id = id
                    form.removeAttr("data-remote");
                    isUserComment = true;
                    openLoginForm();
                }
            }
        });
    }
}

function sign_in_callback(is_signed_in, isPub, pubItemIds,profile_status){
    if (is_signed_in)
    {
        set_KMSignedIn_true();
        // _kmq.push(['identify', KM_user ,{ 'SignedIn' : get_KMSignedIn()}]);
    }
    if(pubItemIds && isPub == "review_token"){
        window.location = '/submit_user_review/' + pubItemIds;
    }else if((isPub && item_id == 0 && !isSubmitTradeyaPg) || (isPub && pubItemIds && pubItemIds.indexOf(item_id) > -1 && isSubmitOffer) || (is_signed_in)){
        // document.location = '/publink';
        if(!isSubmitTradeya && !isSubmitOffer && !isPromoteTradeya && !showOnboarding && !isSubmitTradeyaPg && !unsubscribe_mail && !isContest && isAddShowComment == 0 && !isUserLike && !isUserFollow && !isUserComment && !isUserHaves && !isUserWants && edit_item <= 0){
            if (isLandingPage){
                //redirect after signin
                window.location = '/items?category=all';}
            else
                location.reload();
        }else if(isAddShowComment > 0){
            refreshModal('sign_in_block', false);
            refreshModal('refresh_promote', false);
            if(item_id > 0 && isAddShowComment != 1) refreshModal('comments_section', (jQuery('#comments_table').hasClass('hidedrop') ? false : true));
            if(item_id > 0) refreshModal('offer_section', false);
            if(item_id > 0) refreshModal('mutual_con', false);
            if(isSubmitTradeya){
                // _kmq.push(['record', 'TradeYa Page Main Submit TradeYa Button',{ 'SignedIn' : get_KMSignedIn()}]);
                // _gaq.push(['_trackEvent', 'Activity', 'Clk_SbmTryaFnl', 'Click Submit TradeYa Final Button']);
                isSubmitTradeya = false;
                submitItemForm();
            }
            updateAt();
            if(isAddShowComment == 1) addComment($('#input_comment')[0], item_id);
            if(isAddShowComment > 0) isAddShowComment = 0;
        }else if(isSubmitTradeyaPg){
            refreshModal('sign_in_block', false);
            refreshModal('pst_ofr_and_trd', false);
            stopSpinner();
            // window.location.reload();
            // alert("123");
            // refreshModal('sign_in_block', false);
            // refreshModal('refresh_promote', false);
            // if(item_id > 0 && isAddShowComment != 1) refreshModal('comments_section', (jQuery('#comments_table').hasClass('hidedrop') ? false : true));
            // if(item_id > 0) refreshModal('offer_section', false);
            // if(item_id > 0) refreshModal('mutual_con', false);
            // if(isSubmitTradeya){
            //  _kmq.push(['record', 'TradeYa Page Main Submit TradeYa Button',{ 'SignedIn' : get_KMSignedIn()}]);
            //  _gaq.push(['_trackEvent', 'Activity', 'Clk_SbmTryaFnl', 'Click Submit TradeYa Final Button']);
            //  isSubmitTradeya = false;
            //  submitItemForm();
            // }
            // updateAt();
            // if(isAddShowComment == 1) addComment($('#input_comment')[0], item_id);
            // if(isAddShowComment > 0) isAddShowComment = 0;
        }else if(isSubmitTradeya){
            // _kmq.push(['record', 'TradeYa Page Main Submit TradeYa Button',{ 'SignedIn' : get_KMSignedIn()}]);
            // _gaq.push(['_trackEvent', 'Activity', 'Clk_SbmTryaFnl', 'Click Submit TradeYa Final Button']);
            isSubmitTradeya = false;
            submitItemForm();
        }else if(isSubmitOffer){
            // _kmq.push(['record', 'TradeYa Page Sumbit Offer Button',{ 'Make Offer': offerForm, 'SignedIn' : get_KMSignedIn()}]);
            // _gaq.push(['_trackEvent', 'Activity', 'Clk_SbmOfr', 'Click Submit Offer Link']);
            isSubmitOffer = false;
            submitItemForm();
        }else if (isPromoteTradeya){
            isPromoteTradeya = false;
            location.reload();
        }else if(showOnboarding){
            showOnboarding = false;
            window.location = '/profile';
        }else if(unsubscribe_mail){
            unsubscribe_mail = false;
            window.location = '/edit_settings'
        }else if(isContest){
            window.location = '/contest'
        }else if(isUserLike){
            isUserLike = false;
            likeItem(like_id);
        }else if(isUserFollow){
            isUserFollow = false;
            followUser(follow_id);
        }else if(isUserComment){
            isUserComment = false;
            addComment(comment_id);
        }else if(isUserHaves){
            isUserHaves = false;
            havesUser();
        }else if(isUserWants){
            isUserWants = false;
            wantsUser(want_id);
        }else if(edit_item > 0){
            // edit_item = 0;
            window.location = "/items/"+edit_item+"/edit";
        }
        // hideModal('', true);
        // hideModal('login_box', true);
        closeLoginForm();
        // }else if(is_signed_in){
        //      if(!isSubmitTradeya && !isSubmitOffer){
        //              if (profile_status == 3){
        //                      window.location = '/dashboard';
        //              }else{
        //                      window.location = '/profile?step='+(parseInt(profile_status)+1);
        //              }
        //              // refreshModal('sign_in_block', false);
        //              // refreshModal('sign_in_modal', false);
        //              // refreshModal('sign_up_modal', false);
        //              // refreshModal('refresh_promote', false);
        //              // if(item_id > 0) refreshModal('comments_section', (jQuery('#comments_table').hasClass('hidedrop') ? false : true));
        //              // if(item_id > 0) refreshModal('offer_section', false);
        //              // if (item_id > 0) refreshModal('mutual_con', false);
        //      }else if(isSubmitTradeya){
        //              isSubmitTradeya = false;
        //              submitItemForm();
        //      }else if(isSubmitOffer){
        //              isSubmitOffer = false;
        //              submitItemForm();
        //      }
        //
        //      hideModal('', true);
        //      hideModal('login_box', true);
    }else{
        // jQuery('#signinmessage').text('Invalid email or password.');
    }
}

function refreshModal(modal, isDivOpen){
    // alert('hello');
    if(jQuery('#' + modal + '_div').length > 0){
        jQuery.ajax({
            type: "GET",
            url: "/modals",
            data: modal + "=true&item_id=" + item_id + (isDivOpen ? "&isDivOpen=true" : "") + (isSubmitTradeyaPg ? "&st_pg=true" : "") + ((carousel_cat_id > 0) ? ("&cat_id=" + carousel_cat_id) : ""),
            success: function(msg, status, xhr){
                jQuery("#refresh_modal_div").html(msg);
            },
            error: function(xhr, status){
            }
        });
    }
}

function showSignUpForm(){
    jQuery('#user_spambot_div').html('<input type="checkbox" id="user_captcha" name="user_captcha" style="display:none" value="1" />');
    // return showModal('signup_box');
    $('#signup_box').modal('show');
}

function showSignUpGuestForm(){
    // _kmq.push(['record', 'Login',{ 'Show Login Modal': 'login modal guest signup link', 'SignedIn' : get_KMSignedIn()}]);
    // _gaq.push(['_trackEvent', 'register', 'GuestSignUp', 'Sign Up as Guest from Login Modal']);
    closeLoginForm();
    $('#signup_box_guest').modal('show');
}

function signupFormClose(){
    if(document.getElementById('user_spambot_div'))document.getElementById('user_spambot_div').innerHTML = "";
    $('#chkb_u_cpt').attr('src', 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/checkbox.png');
    // document.getElementById('user_user_photo_photo').value = "";
    // $('#user_img_prew').attr('src', 'https://s3.amazonaws.com/tradeya_prod/tradeya/images/TY_DefaultUser_sm.gif');
    // document.getElementById('signup_box').style.display='none';
    // document.getElementById('fade').style.display='none';
    $('#signup_box').modal('hide');

    jQuery('#error_explanation').text('');
    if(document.getElementById('user_first_name'))document.getElementById('user_first_name').value = "";
    if(document.getElementById('user_last_name'))document.getElementById('user_last_name').value = "";
    if(document.getElementById('signup_email'))document.getElementById('signup_email').value = "";
    if(document.getElementById('signup_conf_email'))document.getElementById('signup_conf_email').value = "";
    if(document.getElementById('signup_pass'))document.getElementById('signup_pass').value = "";
    if(document.getElementById('signup_zip'))document.getElementById('signup_zip').value = "";

    return false;
}

function signupGuestFormClose(){
    if(document.getElementById('guest_user_spambot_div'))document.getElementById('guest_user_spambot_div').innerHTML = "";
    $('#chkb_g_u_cpt').attr('src', 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/checkbox.png');
    // document.getElementById('signup_box_guest').style.display='none';
    // document.getElementById('fade').style.display='none';
    $('#signup_box_guest').modal('hide');
    jQuery('#error_explanation_guest').text('');
    if(document.getElementById('signup_guest_email'))document.getElementById('signup_guest_email').value = "";

    return false;
}

function IsEmail(email) {
 var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
 return regex.test(email);
}

function submitSignUpForm(){
    // if(!canSubmitCanNext) {
    //     $('#error_explanation').text('Please wait while we process');
    //     return;
    // }
    var regex = "^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$";
    var regexnum = /(^\d{5}(-\d{4})?$)|(^[ABCEGHJKLMNPRSTVXY]\d[A-Z]( )?\d[A-Z]\d$)/i;
    var regex_name = "^([a-zA-Z\s\-]*)$";
    // valid email regex
    var regex_email = "/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i";
    
    $("#signUpForm").find("#error_explanation").text("");
    if($("#signUpForm").find("#inputname").val() == "")
        $("#signUpForm").find("#error_explanation").text("Name can't be empty.");
     // else if($("#signUpForm").find("#inputname").val().match(regex_name) == "")
     //     $("#signUpForm").find("#error_explanation").text("Name Format is not correct");
    else if($("#signUpForm").find("#signup_email").val() == "")
        $("#signUpForm").find("#error_explanation").text("Email can't be empty.");
     else if(!IsEmail($("#signUpForm").find("#signup_email").val()))
        $("#signUpForm").find("#error_explanation").text("Email should be valid.");
    else if($("#signUpForm").find("#signup_pass").val() == "")
        $("#signUpForm").find("#error_explanation").text("Password can't be empty.");
    // if(jQuery('#user_first_name').val() == ""){
    //  jQuery('#error_explanation').text('First Name should not be empty');
    // // }else if(jQuery('#user_last_name').val() == ""){
    // //       jQuery('#error_explanation').text('Last Name should not be empty');
    // }else if(jQuery('#signup_email').val() == ""){
    //  jQuery('#error_explanation').text('Email should not be empty');
    // }else if(jQuery('#signup_email').val().match(regex) == null){
    //  jQuery('#error_explanation').text('Email Format not correct');
    // // }else if(jQuery('#signup_email').val() != jQuery('#signup_conf_email').val()){
    // //       jQuery('#error_explanation').text('Emails do not match');
    // }else if(jQuery('#signup_pass').val() == ""){
    //  jQuery('#error_explanation').text('Password should not be empty');
    // }else if(jQuery('#signup_zip').val() == ""){
    //  jQuery('#error_explanation').text('Zip Code should not be empty');
    // }else if(jQuery('#signup_zip').val().match(regexnum) == null){
    //  jQuery('#error_explanation').text('zip code format not valid.');
    // }else if(jQuery('#user_user_photo_id').val() == "" && !jQuery('#user_profile_pic_later_1').is(':checked')){
    //  jQuery('#error_explanation').text('Please choose a Photo.');
    // }else if(isCropping){
    //  jQuery('#error_explanation').text('Please click on \"Done Cropping\" link.');
    // }else if(jQuery('#tandc').is(':checked') == false){
    //  jQuery('#error_explanation').text('Please agree to the terms and conditions');
    // }else if($(jQuery('#signUpForm')).attr('action').indexOf('image_preview') < 0 && !jQuery('#user_captcha').is(':checked')){
    // }else if(!jQuery('#user_captcha').is(':checked')){
    //  jQuery('#error_explanation').text('Please check spambot check box.');
    // alert('Please check spambot check box.');
    else{
        canSubmitCanNext = false;
        // _kmq.push(['record', 'Modal Signup Primary Signup Button',{ 'SignedIn' : get_KMSignedIn()}]);
        // _gaq.push(['_trackEvent', 'register', 'signup', 'Signup Modal']);
        // startSpinner();
         var email_value = $("#signUpForm").find("#signup_email").val();
          var dataString = 'user[email]='+ email_value;
          $.ajax({
              type: "GET",
              url: "/users/check_email",
              data: dataString,
              success: function(data) {
                  $("#signUpForm").find("#error_explanation").text("This email has already been registered with us.");
                  return false;
              },
              error: function(data) {
                  $('#signUpForm').submit();
                  signupFormClose();
                  $('#signup_confirm').modal('show');
              }
          }); 
        
        // setTimeout(function() {jQuery('#signUpForm').submit();}, 500);
    }
}

function submitSignUpGuestForm(){
    if(!canSubmitCanNext){ return false;}
    var regex = "^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$";
    var regexnum = "^[0-9]+$";
    if(jQuery('#signup_guest_f_name').val() == ""){
        jQuery('#error_explanation_guest').text('First Name should not be empty');
    }else if(jQuery('#signup_guest_email').val() == ""){
        jQuery('#error_explanation_guest').text('Email should not be empty');
    }else if(jQuery('#signup_guest_email').val().match(regex) == null){
        jQuery('#error_explanation_guest').text('Email Format not correct');
    }else if(jQuery('#signup_guest_zip').val() == ""){
        jQuery('#error_explanation_guest').text('Zip should not be empty');
    }else{
        canSubmitCanNext = false;
        // _kmq.push(['record', 'Modal Guest Signup Continue Button',{ 'SignedIn' : get_KMSignedIn()}]);
        // _gaq.push(['_trackEvent', 'register', 'signup', 'Guest Signup Modal']);
        startSpinner();
        setTimeout(function() {jQuery('#signUpGuestForm').submit();}, 500);
    }
}

function signUpConfModalOk(){
    // document.getElementById('signup_confirm').style.display='none';
    // document.getElementById('fade').style.display='none';
    $('#signup_confirm').modal('hide');
    if(ab_testing_pg){
        document.location = '/';
    }
    if(isSubmitTradeya){
        isSubmitTradeya = false;
        submitItemForm();
    }
    if(isSubmitOffer){
        isSubmitOffer = false;
        submitItemForm();
    }
}

function submitOnEnterSignupForm(event){
    if (event.keyCode == 13) { // No need to do browser specific checks. It is always 13.
        submitSignUpForm();
    }
}

function submitOnEnterSigninForm(event){
    if (event.keyCode == 13) { // No need to do browser specific checks. It is always 13.
        $('#signInFormSubmitImg').click();
        // sign_in();
    }
}

function searchByZipOnEnter(event){
    // if (event.keyCode == 13) { // No need to do browser specific checks. It is always 13.
    //  submitZipForm();
    //  return false;
    // }
    // }else if (event.which != 99 && event.which != 114 && event.which != 118 && (event.which != 46 || jQuery(this).val().indexOf('.') != -1) && (event.which < 48 || event.which > 57)) {
    //  if (event.preventDefault) { event.preventDefault(); } else { event.returnValue = false; }
    // }
}

// var current_modal = '';
// var curRemoveBack;
// var imgId;
function showModal(modalId, removeBack, imgId){
    $("#"+modalId).modal("show");
    //  if(jQuery('#fade').length == 0) return false;
    //  if(modalId != undefined && modalId != 'undefined' && modalId != ''){
    //          if(isHoverVideo) hideVideoModal();
    //          if(isHoveUserProfile) hideUserProfileModal();
    //          document.getElementById(modalId).style.opacity=0;
    //
    //          document.getElementById(modalId).style.display='block';
    //          if(!removeBack)document.getElementById('fade').style.display='block';
    //
    //          setTimeout(function() {
    //                  makeModelCenter(modalId, imgId);
    //                  if(modalId == 'login_box') jQuery('#user_email').focus();
    //                  if(modalId == 'signup_box') jQuery('#user_first_name').focus();
    //          }, 500);
    //
    //          current_modal = modalId;
    //          curRemoveBack = removeBack;
    //          curImgId = imgId;
    //          isModalVisible = true;
    //  }
    //
    return false;
}

function hideModal(modalId, isClosed){
    $("#"+modalId).modal("hide");
    //  if(modalId == '') modalId = current_modal;
    //  if(modalId != undefined && modalId != 'undefined' && modalId != ''){
    //          document.getElementById(modalId).style.display='none';
    //          document.getElementById('fade').style.display='none';
    //          if(isSubmitTradeya && isClosed) { isSubmitTradeya = false; }
    //          if(isSubmitOffer && isClosed) { isSubmitOffer = false; }
    //
    //          current_modal = '';
    //          curImgId = '';
    //          isModalVisible = false;
    //  }
    //  return false;
}

function submitPasswordForm(){
    var regex ="^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$";
    if(document.getElementById('password_reset_email').value == ""){
        jQuery('#pwdmessage').text('Email address cannot be empty');
    }else if (document.getElementById('password_reset_email').value.match(regex) == null){
        jQuery('#pwdmessage').text('Email address format not correct');
    }else{
        document.getElementById('password_new').submit();
    }
}

function submitResendConfForm(){
    var regex ="^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$";
    if(document.getElementById('confirm_email').value == ""){
        jQuery('#conf_email_msgs').text('Email address cannot be empty');
    }else if (document.getElementById('user_email').value.match(regex) == null){
        jQuery('#conf_email_msgs').text('Email address format not correct');
    }else{
        document.getElementById('resend_password').submit();
    }
}

function resetPasswordForm(){
    if(document.getElementById('password_reset').value == ""){
        jQuery('#resetpwdmessage').text('Password cannot be left blank');
    }else if(document.getElementById('password_reset_confirm').value == ""){
        jQuery('#resetpwdmessage').text('Password Confirmation cannot be left blank');
    }else if (document.getElementById('password_reset').value != document.getElementById('password_reset_confirm').value){
        jQuery('#resetpwdmessage').text('Passwords do not match');
    }else{
        document.getElementById('reset_password_new').submit();
    }
}

function removeOffer(id,manageOffer){
    jQuery.ajax({
        type: "DELETE",
        url: "/trades/" + id,
        data: "isDivOpen=true" + (manageOffer.length>0 ? "&manageOffer="+manageOffer : ""),
        success: function(msg, status, xhr){
            jQuery("#refresh_modal_div").html(msg);
        },
        error: function(xhr, status){
        }
    });
    return false;
}

var user_email = '';
var contact_re_default_val = "";
function contactpopup(trade_id, item_id, email, subject){
    jQuery.ajax({
        url: "/is_signed_in",
        success: function(data){
            if(data == "true"){
                if(email.trim().length > 0 || user_email.length > 0){
                    jQuery('#contact_item_id').val(item_id);
                    jQuery('#contact_trade_id').val(trade_id);
                    if(email.trim().length > 0) jQuery('#contact_from').val(email); else jQuery('#contact_from').val(user_email);
                    jQuery('#contact_re').val(subject);
                    contact_re_default_val = subject;
                    jQuery('#contact_desc').val('');
                    $('#contact_box').modal('show');
                    // showModal('contact_box');
                }
            }else{
                openLoginForm();
                // showModal('login_box');
            }
        }
    });

    return false;
}

function contact(){
    if(document.getElementById('contact_desc').value == ""){
        // showModal('enter_message');
        $('#enter_message').modal('show');
    }else{
        jQuery.ajax({
            url: "/is_signed_in",
            success: function(data){
                if(data == "true"){
                    // hideModal('contact_box', true);
                    $('#contact_box').modal('hide');
                    jQuery.ajax({
                        type: "POST",
                        url: "/contact",
                        data: "trade_id=" + jQuery('#contact_trade_id').val() + "&item_id=" + jQuery('#contact_item_id').val() + "&from=" + jQuery('#contact_from').val() + "&re=" + jQuery('#contact_re').val() + "&msg=" + jQuery('#contact_desc').val() + "&copy2me=" + $('#checkcontact').is(':checked') + "&authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()),
                        success: function(msg, status, xhr){
                            // showModal('msg_sent');
                            $('#msg_sent').modal('show');
                        },
                        error: function(xhr, status){alert('Unable to send!');}
                    });
                }else{
                    $('#contact_modal').modal('hide');
                    openLoginForm();
                    // hideModal('contact_box', false);
                    // showModal('login_box');
                }
            }
        });
        return false;
    }
}

function acceptOfferPopup(trade_id, item_id, email, subject){
    jQuery.ajax({
        url: "/is_signed_in",
        success: function(data){
            if(data == "true"){
                if(email.trim().length > 0 || user_email.length > 0){
                    jQuery.ajax({
                        url:"/update_accept_offer_modal?selected=" + trade_id + "&item_id=" + item_id,
                        success: function(data){

                            // showModal('accept_offer_box');
                            $('#accept_offer_box').modal('show');
                            jQuery('#accept_offer_item_id').val(item_id);
                            jQuery('#accept_offer_trade_id').val(trade_id);
                            if(email.trim().length > 0) jQuery('#accept_offer_from').val(email); else jQuery('#accept_offer_from').val(user_email);
                            jQuery('#accept_offer_re').val(subject);
                            jQuery('#accept_offer_desc').val('');
                        }
                    });
                }
            }else{
                openLoginForm();
                // showModal('login_box');
            }
        }
    });
    return false;
}

function acceptOffer(){
    if(document.getElementById('accept_offer_desc').value == ""){
        // showModal('enter_message');
        $('#enter_message').modal('show');
    }else{
        jQuery.ajax({
            url: "/is_signed_in",
            success: function(data){
                if(data == "true"){
                    // hideModal('accept_offer_box', true);
                    $('#accept_offer_box').modal('hide');
                    jQuery.ajax({
                        type: "POST",
                        url: "/accepted_offers",
                        data: "item_id=" + jQuery('#accept_offer_item_id').val() + "&accepted_offer[trade_id]=" + jQuery('#accept_offer_trade_id').val() + "&from=" + jQuery('#accept_offer_from').val() + "&re=" + jQuery('#accept_offer_re').val() + "&msg=" + jQuery('#accept_offer_desc').val() + "&copy2me=" + $('#checkacceptoffer').is(':checked') + "&authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()),
                        success: function(msg, status, xhr){
                            // showModal('msg_sent');
                            $('#msg_sent').modal('show');
                        },
                        error: function(xhr, status){alert('Unable to send!');}
                    });
                }else{
                    $('#accept_offer_box').modal('hide');
                    openLoginForm();
                    // hideModal('accept_offer_box', false);
                    // showModal('login_box');
                }
            }
        });
        return false;
    }
}

var isPub = false;
var pubItemIds = "";
function openZipPopup(is_pub, pub_item_ids){
    isPub = is_pub;
    pubItemIds = pub_item_ids;
    jQuery.ajax({
        type: "GET",
        url: "/modals",
        data: "zip_div=true",
        success: function(msg, status, xhr){
            jQuery(document.getElementById("refresh_modal_div")).html(msg);
            // hideModal('', false);
            // showModal('zip-div');
            $('.modal.in').modal('hide');
            $('#zip_popup').modal('show');
        },
        error: function(xhr, status){
        }
    });
}

function checkzipform(ssfb){
    var regexnum = /(^\d{5}(-\d{4})?$)|(^[ABCEGHJKLMNPRSTVXY]\d[A-Z]( )?\d[A-Z]\d$)/i;
    var ss = document.getElementById('facebookzip').value;
    if (((ssfb == null) || (ssfb == "")) && (ss == "")){
        $("#zipcheckmessage").text("zip cannot be blank");
    }else if (ss != "" && ss.match(regexnum) == null){
        $("#zipcheckmessage").text("zip code format not valid.");
    }else if (ss.length > 0 && ss.length < 5){
        $("#zipcheckmessage").text("Zip code should be more than 4 digits");
    }else{
        // hideModal('', false);
        if(ss.length == 0){
            jQuery.ajax({
                url: "/update_zip",
                success: function(data){
                    if(data == "failed"){
                        if (!isContest)
                        { document.location = "/users/sign_out"; }
                    }else{
                        sign_in_callback(true, isPub, pubItemIds);
                    }
                }
            });
        }else{
            jQuery.ajax({
                type: "PUT",
                url: "/users",
                data: "user[zip]=" + jQuery('#facebookzip').val() + "&authenticity_token=" + encodeURIComponent($("#zipform input[name=authenticity_token]").val()),
                success: function(msg, status, xhr){
                    if(msg == "failed"){
                        if (!isContest)
                        { document.location = "/users/sign_out"; }
                    }else{
                        sign_in_callback(true, isPub, pubItemIds);
                    }
                },
                error: function(xhr, status){
                }
            });
        }
    }
}

function zipcancelcheck(cusr,auth,czip,ccity,sessfb){
    if ((cusr != null) && (auth != '' ) && ((czip == null) || (czip == "")) && ((ccity == null) || (ccity == "")) && ((sessfb == null) || (sessfb == ""))){
        // _kmq.push(['identify', null ]);
        document.location = "/users/sign_out";
    }else if((cusr != null) && (sessfb != null && sessfb != "")) {
        jQuery.ajax({
            url: "/update_zip",
            success: function(data){
                if(data == "failed"){
                    if(!isContest)
                    { document.location = "/users/sign_out"; }
                }else{
                    sign_in_callback(true, isPub, pubItemIds);
                }
            }
        });
    }
    hideModal('', true);
}

function updateProfile(){
    var regexnum = /(^\d{5}(-\d{4})?$)|(^[ABCEGHJKLMNPRSTVXY]\d[A-Z]( )?\d[A-Z]\d$)/i;
    var zip = document.getElementById('zip_code_edit').value;

    if($('#disp_name_edit').val() == ""){
        $("#profdispnamechkmsg").text("Display name cannot be blank.");
        $('#disp_name_edit').focus();
    }else if(zip == ""){
        $("#profzipchkmsg").text("zip cannot be blank");
        $('#zip_code_edit').focus();
    }else if (zip != "" && zip.match(regexnum) == null){
        $("#profzipchkmsg").text("zip code format is not valid.");
        $('#zip_code_edit').focus();
    }else if (zip.length > 0 && zip.length < 5){
        $("#profzipchkmsg").text("Zip code should be more than 4 digits");
        $('#zip_code_edit').focus();
    }else{
        $('#prof_update_spinner').show();
        $("#profzipchkmsg").text("");
        jQuery.ajax({
            url: "/update_profile",
            data: "disp_name=" + $('#disp_name_edit').val() + "&zip_code=" + $('#zip_code_edit').val() + "&about=" + encodeURIComponent($('#about_info_edit').val()),
            success: function(msg, status, xhr){
                jQuery("#refresh_modal_div").html(msg);
                $('#prof_update_spinner').hide();
            },
            error: function(data){
                $('#prof_update_spinner').hide();
                alert("Something went wrong. Please try again.");
            }
        });
    }
}

function aboutWordCount(ta, count){
    if(typeof(count) == 'undefined') {count = 500;}
    var len = ta.value.length;
    if (len > count) {
        ta.value = ta.value.substring(0, count);
    }else {
        $('#about_word_count').text("<" + len + "/" + count +">");
    }
}

$(function(){
    $(window).resize(function(){
        var right =( ($(window).width() - $('#publicpg').width()) / 2) - 15
        // $('#logout_dropdown').css('right', right + 'px');

    });

    $(document).scroll(function(){
        var h = $(window).height();
        if($(document).scrollTop() > (h - 160)){
            $('#scroll_top').fadeIn('slow');
        }else{
            $('#scroll_top').fadeOut('slow');
        }
        $('#label_scroll').text('Win H:' + $(window).height() + 'Top:' + $(document).scrollTop() + ' Left: ' + $(document).scrollLeft());
    });
    $(document).click(function(){
        // if(isHoverVideo) {hideVideoModal();}
        // if(isHoveUserProfile) {hideUserProfileModal();}

        if(jQuery('#winespinner').length > 0) jQuery('#winespinner').hide();
        if(jQuery('#offer_title_dropdownbox').length > 0) jQuery("#offer_title_dropdownbox").hide();
        if(jQuery('#offer_title_resultdiv').length > 0) jQuery("#offer_title_resultdiv").hide();
    });
    $(document).keyup(function(e) {
        if(e.keyCode == 27 && isHoverVideo) {hideVideoModal();}
        if(e.keyCode == 27 && isHoveUserProfile){ hideUserProfileModal();}

        if(e.keyCode == 27 && jQuery('#winespinner').length > 0) jQuery('#winespinner').hide();
        if(e.keyCode == 27 && jQuery('#offer_title_dropdownbox').length > 0) jQuery("#offer_title_dropdownbox").hide();
        if(e.keyCode == 27 && jQuery('#offer_title_resultdiv').length > 0) jQuery("#offer_title_resultdiv").hide();
    });

    $(window).focus(function(){
        isPageActive = true;
    });
    $(window).blur(function(){
        isPageActive = false;
    });

    updateAt();
});

function updateAt(){
    // jQuery.ajax({
    //     url: "/at",
    //     success: function(msg, status, xhr){}
    // });
}

//for test javascript write code here and click on How this works
function test(){
    alert($('#user_profile_photo input[id=user_user_photo_photo]').val());
    return false;
    alert($('#xyz'));
    alert($('#xyz').length);
    alert($('#refresh_modal_div').length);
}

function adjustFooter(){
    // var h = $(window).height();
    // var wh = $('#wrapper').height();
    // var fh = $('#footer').height();
    // if((wh + fh) <= h){
    //  $('#footer').css('top', (h - fh));
    // }else{
    //  $('#footer').css('top', wh + 0);
    // }
    if(isModalVisible) setTimeout(function() {makeModelCenter(current_modal, curImgId);}, 0);
}

function makeModelCenter(divId, imgId){
    var h = $(window).height();
    var w = $(window).width();
    var dh = $('#' + divId).height();
    var dw = $('#' + divId).width();
    if(isHoverVideo){
        var top = ((h - dh) / 2) + $(window).scrollTop();
        if(dh > h) top = top + (((dh - h) / 2) + 70);
    }else{
        var top = 80 + $(window).scrollTop();
    }
    var left = ((w - dw) / 2) + $(window).scrollLeft();
    // if(dh > h) top = top + (((dh - h) / 2) + 70);
    $('#' + divId).css('top', top + 'px');
    $('#' + divId).css('left', left + 'px');
    document.getElementById(divId).style.opacity=100;
}

function getZoomLevel(){
    var screenCssPixelRatio = (window.outerWidth - 8) / window.innerWidth;
    var zoomLevel = -5;
    if (screenCssPixelRatio >= .46 && screenCssPixelRatio <= .54) {
        zoomLevel = -4;
    } else if (screenCssPixelRatio <= .64) {
        zoomLevel = -3;
    } else if (screenCssPixelRatio <= .76) {
        zoomLevel = -2;
    } else if (screenCssPixelRatio <= .92) {
        zoomLevel = -1;
    } else if (screenCssPixelRatio <= 1.10) {
        zoomLevel = 0;
    } else if (screenCssPixelRatio <= 1.32) {
        zoomLevel = 1;
    } else if (screenCssPixelRatio <= 1.58) {
        zoomLevel = 2;
    } else if (screenCssPixelRatio <= 1.90) {
        zoomLevel = 3;
    } else if (screenCssPixelRatio <= 2.28) {
        zoomLevel = 4;
    } else if (screenCssPixelRatio <= 2.70) {
        zoomLevel = 5;
    }
    return zoomLevel;
}

// function submitSignUpFormie(){
//      _kmq.push(['record', 'signup modal']);
//      var regex = "^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$";
//      var regexnum = "^[0-9]+$";
//      if(jQuery('#user_first_name').val() == ""){
//              jQuery('#error_explanation').text('First Name should not be empty');
//      }else if(jQuery('#user_last_name').val() == ""){
//              jQuery('#error_explanation').text('Last Name should not be empty');
//      }else if(jQuery('#signup_email').val() == ""){
//              jQuery('#error_explanation').text('Email should not be empty');
//      }else if(jQuery('#signup_email').val().match(regex) == null){
//              jQuery('#error_explanation').text('Email Format not correct');
//      }else if(jQuery('#signup_email').val() != jQuery('#signup_conf_email').val()){
//              jQuery('#error_explanation').text('Emails do not match');
//      }else if(jQuery('#signup_pass').val() == ""){
//              jQuery('#error_explanation').text('Password should not be empty');
//      }else if(jQuery('#signup_zip').val() == ""){
//              jQuery('#error_explanation').text('Zip Code should not be empty');
//      }else if(jQuery('#signup_zip').val().match(regexnum) == null){
//              jQuery('#error_explanation').text('Only numbers are allowed for zip code');
//      }else if(jQuery('#user_user_photo_photo').val() == ""){
//              jQuery('#error_explanation').text('Please choose a Photo.');
//      }else if(jQuery('#tandc').is(':checked') == false){
//              jQuery('#error_explanation').text('Please agree to the terms and conditions');
//      }
//      return true;
// }
//
// function imagePreviewie(f, form_id, img_prev_id, item){
//      jQuery('#ind_' + img_prev_id).show();
//      document.getElementById('ind_' + img_prev_id).style.display = 'block';
//
//      var f = jQuery('#' + form_id);
//      var tAction = f.attr('action');
//      var have_target = f.attr('target') == 'if_ip_upload' ? true : false;
//      if(!have_target)f.attr('target', 'if_ip_upload');
//      f.attr('action', '/image_preview?img_prev_id=' + img_prev_id + '&itemimg=' + item + '&tAction');
//      return true;
// }

// function hideShowDiscoverDropdown(){
//      $('#about_dropdown').addClass('hidedrop');
//     $('#about').removeClass('classbold');
//     $('.about_drp_grey').hide();
//     $('.about_drp_blue').show();
//     $('#logout_dropdown').addClass('hidedrop');
//     $('#user_log').removeClass('classbold');
//     $('.log_drp_grey').hide();
//     $('.log_drp_blue').show();
//      $('#tradeya_dropdown').toggleClass('hidedrop');
//     $('#tradeya_drp').toggleClass('classbold');
//     if ($('#tradeya_drp').attr("class") == "img-swap") {
//         $('.tradeya_drp_grey').hide();
//         $('.tradeya_drp_blue').show();
//     } else {
//      $('.tradeya_drp_blue').hide();
//              $('.tradeya_drp_grey').show();
//     }
//     return false;
// }
function hideShowDiscoverDropdown(){
    $('#logout_dropdown').addClass('hidedrop');
    $('#user_log').removeClass('classbold');
    $('#tradeya_dropdown').css('display','block');
    // $('#tradeya_drp').toggleClass('classbold');
    // $('#tradeya_drp_new').css('display','block');
    if ($('#tradeya_drp').attr("class") == "img-swap") {
        $('#tradeya_drp_new').hide();
        $('#tradeya_drp').show();
    } else {
        $('#tradeya_drp').hide();
        $('#tradeya_drp_new').show();
    }
    return false;
}
function hideShowAbtDropdownWork(){
    $('#tradeya_dropdown').addClass('hidedrop');
    $('#tradeya_drp').removeClass('classbold');
    $('.tradeya_drp_blue').show();
    $('.tradeya_drp_grey').hide();
    $('#logout_dropdown').addClass('hidedrop');
    $('#user_log').removeClass('classbold');
    $('.log_drp_grey').hide();
    $('.log_drp_blue').show();
    $('#about_dropdown').addClass('hidedrop');
    $('#about').toggleClass('classbold');
    if ($('#about').attr("class") == "img-swap") {
        $('.about_drp_grey').hide();
        $('.about_drp_blue').show();
    } else {
        $('.about_drp_blue').hide();
        $('.about_drp_grey').show();
    }
    return false;
}
function hideShowAbtDropdown(){
    $('#tradeya_dropdown').addClass('hidedrop');
    $('#tradeya_drp').removeClass('classbold');
    $('.tradeya_drp_blue').show();
    $('.tradeya_drp_grey').hide();
    $('#logout_dropdown').addClass('hidedrop');
    $('#user_log').removeClass('classbold');
    $('.log_drp_grey').hide();
    $('.log_drp_blue').show();
    $('#about_dropdown').toggleClass('hidedrop');
    $('#about').toggleClass('classbold');
    if ($('#about').attr("class") == "img-swap") {
        $('.about_drp_grey').hide();
        $('.about_drp_blue').show();
    } else {
        $('.about_drp_blue').hide();
        $('.about_drp_grey').show();
    }
    return false;
}

function hideShowLogDropdown(){
    $('#logout_dropdown').toggleClass('hidedrop');
    $('#tradeya_dropdown').addClass('hidedrop');
    $('.tradeya_drp_blue').show();
    $('.tradeya_drp_grey').hide();
    $('#about_dropdown').addClass('hidedrop');
    $('#about').removeClass('classbold');
    $('.about_drp_grey').hide();
    $('.about_drp_blue').show();
    if ($('#user_log').attr("class") == "img-swap") {
        $('.log_drp_grey').hide();
        $('.log_drp_blue').show();
    } else {
        $('.log_drp_blue').hide();
        $('.log_drp_grey').show();
    }
    var left = $("#usr_name_li").position().left;
    var ss = $("#usr_name_li").width();
    $("#logout_dropdown").css("width",ss+'px');
    $('#logout_dropdown').css('left', left + 'px');
    return false;
}

function hideShowDropdown(){
    $('.tradeya_drp_grey').hide();
    $('.about_drp_grey').hide();
    $('.log_drp_grey').hide();
}

// Live and Completed tabs
// $("#livetablink").live("click", function(){
//      $("#livetablink a img").attr("src","https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/live_selected.png");
//      $("#completedtablink a img").attr("src","https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/completed.png");
//      $("#livetab").css("display","block");
//      $("#completedtab").css("display","none");

// });
// $("#completedtablink").live("click", function(){
//      $("#completedtablink a img").attr("src","https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/completed_selected.png");
//      $("#livetablink a img").attr("src","https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/live.png")
//      $("#completedtab").css("display","block");
//      $("#livetab").css("display","none");

// });

// Show and Hide reviews
function showHideReview(id){
    $('#showReview_'+id).live('click', function(){
        $('#review_section_div_'+id).css("display", "block");
        $('#showReview_'+id).css("display", "none");
        $('#hideReview_'+id).css("display", "block");
        $('#contact_'+id).hide();
        $('#acceptoffer_'+id).hide();
        $('#ofr_acptd_text_'+id).hide();
        $('.rating_'+id).hide();

        return false;
    });
    $('#hideReview_'+id).live('click', function(){
        $('#review_section_div_'+id).css("display", "none");
        $('#showReview_'+id).css("display", "block");
        $('#hideReview_'+id).css("display", "none");
        $('#contact_'+id).show();
        $('#acceptoffer_'+id).show();
        $('#ofr_acptd_text_'+id).show();
        $('.rating_'+id).show();

        return false;
    });
}

// Show and Hide Mutual connections
function showHideConnect(id){
    $('#showConnect_'+id).live('click', function(){
        $('#mutual_connect_div_'+id).css("display", "block");
        $('#showConnect_'+id).css("display", "none");
        $('#hideConnect_'+id).css("display", "block");
        $('#contact_'+id).hide();
        $('#acceptoffer_'+id).hide();
        $('#ofr_acptd_text_'+id).hide();
        $('.rating_'+id).hide();

        return false;
    });
    $('#hideConnect_'+id).live('click', function(){
        $('#mutual_connect_div_'+id).css("display", "none");
        $('#showConnect_'+id).css("display", "block");
        $('#hideConnect_'+id).css("display", "none");
        $('#contact_'+id).show();
        $('#acceptoffer_'+id).show();
        $('#ofr_acptd_text_'+id).show();
        $('.rating_'+id).show();

        return false;
    });
}
function setDefaultSelect(){
    $("#completedtablink a img").attr("src","https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/completed_selected.png");
    $("#livetablink a img").attr("src","https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/live.png")
    $("#completedtab").css("display","block");
    $("#livetab").css("display","none");

}

function isNumberKey(evt){
    if (event.which != 99 && event.which != 114 && event.which != 118 && (event.which != 46 || jQuery(this).val().indexOf('.') != -1) && (event.which < 48 || event.which > 57)) {
        if (event.preventDefault) { event.preventDefault(); } else { event.returnValue = false; }
    }
}

function submitZipForm(){
    zip = $('#zipcode_text').val();
    regexp = /(^\d{5}(-\d{4})?$)|(^[ABCEGHJKLMNPRSTVXY]\d[A-Z]( )?\d[A-Z]\d$)/i;
    if(zip != null && zip != "" && zip != "Enter zip code" && zip.match(regexp) != null){
        $('#searchByZipForm').submit();
    }else{
        alert("zip code format not valid.");
    }
    return false;
}

function validateMultipleOffers(index,item_id){
    var n;
    var selected = "";
    for(n = 1;n <= index; n++){
        if($('#accept_check_' + n).is(':checked')){
            selected == "" ? selected = $('#selected_offer_' + n).val() : selected = selected + "," + $('#selected_offer_' + n).val();
        }
    }
    if(selected == null || selected == ""){
        // showModal('offertoselect');
        $('#offertoselect').modal('show');
    }else{
        acceptMultipleOffersPopup(selected,item_id);
    }
}

function acceptMultipleOffersPopup(selected,item_id){
    jQuery.ajax({
        url: "/is_signed_in",
        success: function(data){
            if(data == "true"){
                jQuery.ajax({
                    url:"/update_accept_offer_modal?selected=" + selected + "&item_id=" + item_id,
                    success: function(data){
                        // showModal('accept_offer_box');
                        $('#accept_offer_box').modal('show');
                        jQuery('#accept_offer_item_id').val(item_id);
                        jQuery('#accept_offer_trade_id').val(selected);
                        // if(email.trim().length > 0) jQuery('#accept_offer_from').val(email); else jQuery('#accept_offer_from').val(user_email);
                        // jQuery('#accept_offer_re').val(subject);
                        // jQuery('#accept_offer_desc').val('');
                    }
                });
            }else{
                openLoginForm();
            }
        }
    });

    return false;
}

function acceptMultipleOffers(){
    if(document.getElementById('accept_offer_desc').value == ""){
        // showModal('enter_message');
        $('#enter_message').modal('show');
    }else{
        jQuery.ajax({
            url: "/is_signed_in",
            success: function(data){
                if(data == "true"){
                    // hideModal('accept_offer_box', true);
                    $('#accept_offer_box').modal('hide');
                    jQuery.ajax({
                        type: "POST",
                        url: "/accept_multiple_offers",
                        data: "item_id=" + jQuery('#accept_offer_item_id').val() + "&trades=" + jQuery('#accept_offer_trade_id').val() + "&from=" + jQuery('#accept_offer_from').val() + "&re=" + jQuery('#accept_offer_re').val() + "&msg=" + jQuery('#accept_offer_desc').val() + "&copy2me=" + $('#checkacceptoffer').is(':checked') + "&authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()),
                        success: function(msg, status, xhr){
                            // showModal('want_end_trd');
                            $('#want_end_trd').modal('show');
                        },
                        error: function(xhr, status){alert('Unable to send!');}
                    });
                }else{
                    // hideModal('accept_offer_box', false);
                    $('#accept_offer_box').modal('hide');
                    openLoginForm();
                }
            }
        });
        return false;
    }
}

function completeTradeya(){
    jQuery.ajax({
        url: "/is_signed_in",
        success: function(data){
            if(data == "true"){
                // hideModal('want_end_trd', true);
                $('#want_end_trd').modal('hide');
                jQuery.ajax({
                    type: "POST",
                    url: "/complete_trade",
                    data: "item_id=" + jQuery('#accept_offer_item_id').val() + "&authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()),
                    success: function(msg, status, xhr){
                        // showModal('msg_sent_tradeya_end');
                        $('#msg_sent_tradeya_end').modal('show');
                    },
                    error: function(xhr, status){alert('Unable to send!');}
                });
            }else{
                // hideModal('want_end_trd', false);
                $('#want_end_trd').modal('hide');
                openLoginForm();
            }
        }
    });

    return false;
}

function showTimeRemaining(){
    // hideModal("want_end_trd",true);
    // showModal("tradeya_end");
    $('#want_end_trd').modal('hide');
    $('#tradeya_end').modal('show');
    return false;
}


function customScroll(div_id){
    if($(div_id).length > 0)
    {
        $("html,body").animate({'scrollTop': $(div_id).offset().top}, 400);
        return false;
    }
}

//Other Offers
function otherOffers(){
    if ($("#other_offer").hasClass('hidedrop')){
        $("#other_offer").removeClass('hidedrop');
        $("#offer_heading_other img").attr('src','https://s3.amazonaws.com/tradeya_prod/tradeya/images/arrow_open.png');
        $('#confrm_select_div_other').show();
    }else{
        $("#other_offer").addClass('hidedrop');
        $("#offer_heading_other img").attr('src','https://s3.amazonaws.com/tradeya_prod/tradeya/images/arrow_close.png');
        $('#confrm_select_div_other').hide();
    }

}
function acceptedOffers(){
    if ($("#accepted_offer").hasClass('hidedrop')){
        $("#accepted_offer").removeClass('hidedrop');
        $("#offer_heading_accepted img").attr('src','https://s3.amazonaws.com/tradeya_prod/tradeya/images/arrow_open.png');
    }else{
        $("#accepted_offer").addClass('hidedrop');
        $("#offer_heading_accepted img").attr('src','https://s3.amazonaws.com/tradeya_prod/tradeya/images/arrow_close.png');
    }

}

function completedItemForm(){
    $('#promotenowclicked_btn').show();
    $('.makeofferclicked_btn').show();
    $('.kick_off_back').hide();
}

function prepareDelete(id, manageOffer){
    $('#del_ofr_id').val(id);
    if (manageOffer != undefined)
    { $('#request_manage_offer').val(manageOffer); }
    $('#delete_offer').modal('show');
}

// funxtions for spinner
function startSpinner()
{
    // $('#spinner').fadeIn();
}

function stopSpinner()
{
    // $('#spinner').hide();
}

function bindAjaxSpinner()
{
    // $('.click').click(function() {
    //  var position = $(this).offset();
    //  //position image and show
    //  $('#spinner').css({ top: position.top , left: position.left + $(this).width() + 30, zIndex:  2000}).fadeIn();
    // });
    // $('.position-click').click(function() {
    //  var position = $(this).offset();
    //  //position image
    //  $('#spinner').css({ top: position.top , left: position.left + $(this).width() + 30, zIndex:  2000});
    // });
    // $('.cancel-click').click(function(){
    //  $('#spinner').hide();
    // });
    // $("#spinner").bind("ajaxSend", function(e, jqxhr, settings) {
    //  // skip ajax spinner in these cases
    //  if (settings.url == '/refresh_user_greet_notification_count.js' || settings.url == '/refresh_alert_count_and_show_new.js' || settings.url == "/at" || settings.url == "/hello_modal_timer") {
    //                  $(this).hide();
    //          }
    //   else{
    //          $(this).fadeIn();
    //   }
    // }).bind("ajaxStop", function() {
    //  $(this).hide();
    // }).bind("ajaxError", function() {
    //  $(this).hide();
    // }).bind("ajaxComplete", function() {
    //  $(this).hide();
    // });

}

function submitReviewForm(){
    if($('#submit_review_field').val() == ""){
        alert("Review text can't left blank.");
    }else{
        $('#user_review_form').submit();
    }
    return false;
}

function editProfileImage(){
    if(!(jQuery('#selected_photo_file').text() == "" || jQuery('#selected_photo_file').text() == "No file selected")){
        jQuery('#user_profile_photo').submit();
        jQuery('#selected_photo_file').text("No file selected");
        jQuery("#" + form_id + " input[id=user_user_photo_photo]").val('');
        jQuery("#ind_user_prof_img_crop").hide();
        // hideModal('usr_profile_pic', true);
        $('#usr_profile_pic').modal('hide');
        jQuery('#usr_profile_pic').hide();
    }
    return false;
}


function requestRemove(id){
    reviewDiv= $('#remove_review_'+id)
    if (reviewDiv.length > 0)
    {
        jQuery.ajax({
            type: "POST",
            url: "/review_flag",
            data: "id=" + id,
            success: function(msg, status, xhr){
                reviewDiv.children('#flag').toggle();
                reviewDiv.children('#unflag').toggle();
            },
            error: function(xhr, status){
                alert('unable to send request');}
        });
    }
}

function showPromote(){
    document.getElementById('promote_now').style.display='block';
    document.getElementById('fade').style.display='block';
    document.getElementById('promote_btn').style.display='none';
    document.getElementById('promotenowclicked_btn').style.display='block';
    return false;
}

function hidePromote(){
    document.getElementById('promote_now').style.display='none';
    document.getElementById('fade').style.display='none';
    try{
        document.getElementById('promotenowclicked_btn').style.display='none';
        document.getElementById('promote_btn').style.display='block';
    }catch(err){
    }
    return false;
}

var promoteNowPrevId = 0;
function openPromoteNowPopup(item_id){
    try{if (event.preventDefault) { event.preventDefault(); } else { event.returnValue = false; }}catch(err){}
    if(promoteNowPrevId == item_id){
        // showModal('promote_now');
        $('#promote_now').modal('show');
    }else{
        jQuery.ajax({
            type: "GET",
            url: "/modals",
            data: "promotenow_modal=true&item_id=" + item_id,
            success: function(msg, status, xhr){
                jQuery(document.getElementById("refresh_modal_div")).html(msg);
                // showModal('promote_now');
                $('#promote_now').modal('show');
                try{FB.XFBML.parse();}catch(err){}
                try{twttr.widgets.load();}catch(err){}

                promoteNowPrevId = item_id;
            },
            error: function(xhr, status){
            }
        });
    }
    return false;
}

function postponeTradeya(){
    jQuery.ajax({
        url: "/is_signed_in",
        success: function(data){
            if(data == "true"){
                // hideModal('post_trd', true);
                $('#post_trd').modal('hide');
                jQuery.ajax({
                    type: "POST",
                    url: "/postpone_trade",
                    data: "item_id=" + jQuery('#post_trd_id').val() + "&authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()),
                    success: function(msg, status, xhr){
                        if(msg == "success"){
                            location.reload();
                        }else{
                            // hideModal('post_trd', true);
                            $('#post_trd').modal('hide');
                            alert("Server error!");
                        }
                    },
                    error: function(xhr, status){alert('Server error!');}
                });
            }else{
                // hideModal('post_trd', true);
                $('#post_trd').modal('hide');
                openLoginForm();
            }
        }
    });
    return false;
}

function confirmDeleteTradeya(item_id){
    $('#del_trd_id').val(item_id);
    // showModal('delete_trd');
    $('#delete_trd').modal('show');
    return false;
}

function deleteTradeya(){
    jQuery.ajax({
        url: "/is_signed_in",
        success: function(data){
            if(data == "true"){
                // hideModal('delete_trd', true);
                $('#delete_trd').modal('hide');
                jQuery.ajax({
                    type: "DELETE",
                    url: "/items/" + jQuery('#del_trd_id').val(),
                    data: "&authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()),
                    success: function(msg, status, xhr){
                        if(msg == "success"){
                            location.reload();
                        }else{
                            // hideModal('delete_trd', true);
                            $('#delete_trd').modal('hide');
                            alert("Server error!");
                        }
                    },
                    error: function(xhr, status){alert('Server error!');}
                });
            }else{
                // hideModal('delete_trd', true);
                $('#delete_trd').modal('hide');
                openLoginForm();
            }
        }
    });
    return false;
}

function submitEditAccountSettingsForm(){
    jQuery('#error_notification_settings').text('');
    jQuery('#error_account_settings').text('');
    var regex = "^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$";
    if(jQuery('#user_first_name').val() == ""){
        jQuery('#error_account_settings').text('First Name should not be empty');
    }else if(jQuery('#user_last_name').val() == ""){
        jQuery('#error_account_settings').text('Last Name should not be empty');
    }else if(jQuery('#user_email').val() == ""){
        jQuery('#error_account_settings').text('Email should not be empty');
    }else if(jQuery('#user_email').val().match(regex) == null){
        jQuery('#error_account_settings').text('Email Format not correct');
    }else if((jQuery('#user_allow_mobile').val() == "false" || jQuery('#user_allow_mobile').val() == 0) && jQuery('#user_notify_via_mobile').val() == 1)
    {
        jQuery('#error_notification_settings').text('You cannot select NOTIFICATIONS via MOBILE as your phone number is not verified.');
    }else{
        startSpinner();
        jQuery('#account_settings_form').submit();
    }

}

function changePassword()
{
    jQuery('#error_change_password').css('display', "none");
    jQuery('#error_change_password').text('');
    var regex ="^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$";

    if ($('user_current_password').length > 0 && $('user_current_password').value == '')
    {
	jQuery('#error_change_password').css('display', "block");
        jQuery('#error_change_password').text('Enter Old Password');
    }
    else if (document.getElementById('user_new_password').value == ''){
	jQuery('#error_change_password').css('display', "block");
        jQuery('#error_change_password').text('Enter New Password');
    }else if (document.getElementById('user_new_password_confirmation').value == ''){
	jQuery('#error_change_password').css('display', "block");
        jQuery('#error_change_password').text('Re-Enter New Password');
    }else if (document.getElementById('user_new_password_confirmation').value != document.getElementById('user_new_password').value){
	jQuery('#error_change_password').css('display', "block");
        jQuery('#error_change_password').text('New Password Mismatch. Re-Enter New Password.');
    }else{
        jQuery.ajax({
            type: "POST",
            url: "/change_user_password",
            data: "user[current_password]=" + jQuery('#user_current_password').val() + "&user[password]=" + jQuery('#user_new_password').val()+ "&user[password_confirmation]=" + jQuery('#user_new_password_confirmation').val() + "&authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()),
            success: function(msg, status, xhr){
                jQuery("#refresh_modal_div").html(msg);
                // jQuery("#refresh_modal_div").hide();
                $('#change_password_form').remove();
                $('#c_pwd_modal').append("<b align='center'>Your password has been changed</b>");
                //$('#c_pwd_modal').modal('hide');
            },
            error: function(xhr, status){
            }
        });
    }
}

function cancelChangePassword()
{
    jQuery('#error_change_password').css('display', 'none');
    jQuery('#error_change_password').text('');
    jQuery('#user_current_password').val('');
    jQuery('#user_new_password').val('');
    jQuery('#user_new_password_confirmation').val('');
    // return hideModal('usr_pwd_chng', true);
    $('#c_pwd_modal').modal('hide');
}

function showDeleteCommentConfirm(id){
    $('#rmv_cmt_id').val(id);
    $('#delete_comment').modal("show");
    // showModal('delete_comment');
    return false;
}

function deleteComment(){
    jQuery.ajax({
        url: "/is_signed_in",
        success: function(data){
            if(data == "true"){
                // hideModal('delete_comment', true);
                $('#delete_comment').modal('hide');
                jQuery.ajax({
                    type: "DELETE",
                    url: "/comments/" + jQuery('#rmv_cmt_id').val() + ".js",
                    data: "&authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()) + "&isDivOpen=true",
                    success: function(msg, status, xhr){
                        // jQuery("#refresh_modal_div").html(msg);
                    },
                    error: function(xhr, status){alert('Server error!');}
                });
            }else{
                // hideModal('delete_comment', true);
                $('#delete_comment').modal('hide');
                openLoginForm();
            }
        }
    });
    return false;
}
function offerer_page_tooltip_show(){
    var h = $(window).width();
    if (h >= 1100){
        $('.offerer_page_tooltip').css('display','inline')
    }else{
        $('.offerer_page_tooltip_right').css('display','inline')
    }
}
function offerer_page_tooltip_hide(){
    $('.offerer_page_tooltip').css('display','none');
    $('.offerer_page_tooltip_right').css('display','none')
}
function current_tradeya_tooltip_show(){
    var h = $(window).width();
    if (h >= 1100){
        $('.current_tradeyas_tooltip').css('display','block')
    }else{
        $('.current_tradeyas_tooltip_right').css('display','block')
    }
}
function current_tradeya_tooltip_hide(){
    $('.current_tradeyas_tooltip').css('display','none');
    $('.current_tradeyas_tooltip_right').css('display','none')
}
function tradeya_history_tooltip_show(){
    var h = $(window).width();
    if (h >= 1100){
        $('.tradeyas_history_tooltip').css('display','block')
    }else{
        $('.tradeyas_history_tooltip_right').css('display','block');
    }
}
function tradeya_history_tooltip_hide(){
    $('.tradeyas_history_tooltip').css('display','none');
    $('.tradeyas_history_tooltip_right').css('display','none')
}
function user_current_offer_tooltip_show(){
    var h = $(window).width();
    if (h >= 1100){
        $('.current_offer_tooltip').css('display','block')
    }else{
        $('.current_offer_tooltip_right').css('display','block');
    }
}
function user_current_offer_tooltip_hide(){
    $('.current_offer_tooltip').css('display','none');
    $('.current_offer_tooltip_right').css('display','none')
}
function user_past_offer_tooltip_show(){
    var h = $(window).width();
    if (h >= 1100){
        $('.successful_offer_tooltip').css('display','block');
    }else{
        $('.successful_offer_tooltip_right').css('display','block');
    }
}
function user_past_offer_tooltip_hide(){
    $('.successful_offer_tooltip').css('display','none');
    $('.successful_offer_tooltip_right').css('display','none')
}
function publisher_page_offer_tooltip_show(){
    var h = $(window).width();
    if (h >= 1100){
        $('.publisher_page_tooltip').css('display','block');
    }else{
        $('.publisher_page_tooltip_right').css('display','block');
    }
    $("#current_offer").removeClass('hidedrop');
    $("#offers_section_current img").attr('src','https://s3.amazonaws.com/tradeya_prod/tradeya/images/arrow_open.png');
    $('#confrm_select_div').show();

}
function publisher_page_offer_tooltip_hide(){
    $('.publisher_page_tooltip').css('display','none');
    $('.publisher_page_tooltip_right').css('display','none')
}

function profile_next_submit(current)
{
    $('#error_message_'+current).hide();
    $('#error_message_interests_wish').hide();
    var wish = $('#step3_user_wish').val();
    var selected_ids = $('#step_' + current +'_selected').val();
    if (selected_ids.split(',').length > 2)
    {
        if ((current == 3) && (wish.length < 1))
        {
            $('#error_message_interests_wish').show();
            return;
        }
        jQuery.ajax({
            type: "POST",
            url: "/update_user_categories",
            data: "step_" + current + "=" + selected_ids + "&authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()) + ((current == 3) ? "&wish="+encodeURIComponent(wish) : ""),
            success: function(msg, status, xhr){
                if (msg == "error"){
                    location.reload(true);
                    return;
                }
                $('.step1').hide();
                $('.step2').hide()
                $('.step3').hide();
                if (current == 1)
                    $('.step2').show();
                else if (current == 2)
                    $('.step3').show();
                else
                { $('.step3').show();
                  $('#next_disabled_step_3').show();
                  $('#next_enabled_step_3').hide();
                  $('#finish_spinner').show();
                  $('#error_message_interests_wish').text('TradeYa is searching a match for you...');
                  $('#error_message_interests_wish').show();
                  //window.location = '/execute_matching';
                  jQuery.ajax({
                      type: "GET",
                      url: "/execute_matching",
                      success: function(msg, status, xhr){
                          window.location = msg;
                      }
                  });
                }
            },
            error: function(xhr, status){
                alert("error");
            }
        });
    }
    else
        $('#error_message_'+current).show();

}

function profile_save_submit(current)
{
    $('#error_message_'+current).hide();
    $('#error_message_interests_wish').hide();
    var wish = $('#step3_user_wish').val();
    var selected_ids = $('#step_' + current +'_selected').val();
    if (selected_ids.split(',').length > 2)
    {
        if ((current == 3) && (wish.length < 1))
        {
            $('#error_message_interests_wish').show();
            return;
        }
        jQuery.ajax({
            type: "POST",
            url: "/update_user_categories",
            data: "update_queue=true&step_" + current + "=" + selected_ids + "&authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()) + ((current == 3) ? "&wish="+encodeURIComponent(wish) : ""),
            success: function(msg, status, xhr){
                window.location = '/dashboard';
            },
            error: function(xhr, status){
                window.location = '/';
            }
        });
    }
    else
        $('#error_message_'+current).show();

}

function initialize_profile_page(user_goods_ids,user_services_ids,user_interests_ids,user_wish,step,g_img,s_img,i_img)
{
    var selected_ids,id,index;
    // show user's selected goods
    if (user_goods_ids.length > 0)
    {
        selected_ids = user_goods_ids.split(',');
        for(index = 0; index < selected_ids.length; index++)
        {
            id = selected_ids[index]
            selectMultipleCategory('#item_'+id, 'item_'+id, id, 'step_1_selected', 'step1_category_selected',true,'check_next_button(1);potential_match(1);show_select_all(\'#item_'+id+'\',true);/*_kmq.push([\'record\', \'onboarding x button removes things you like\',{ \'SignedIn\' : get_KMSignedIn()}]); _gaq.push([\'_trackEvent\', \'onboarding\', \'Clk_removesubcat\', \'Clicks to Remove On Any Items In Things You Like\']);*/');
            show_select_all('#item_'+id);
        }
        if (g_img.length > 0)
        {
            var result = g_img.split('##');
            if (result[1] == 'img')
            {
                $('#step1_potential_match_img > img').attr('src',result[0]);
                $('#step1_potential_match_img').show();
                $('#itemPlayer_step1').hide();
            }
            else if (result[1] == 'video')
            {
                $('#itemPlayer_step1').css('display','block');
                playVideo('itemPlayer_step1', result[0], false, null);
                $('#step1_potential_match_img').hide();
            }
            $('#step1_no_potential_match').hide();
        }
    }
    // show user's selected services
    if (user_services_ids.length > 0)
    {
        selected_ids = user_services_ids.split(',');
        for(index = 0; index < selected_ids.length; index++)
        {
            id = selected_ids[index]
            selectMultipleCategory('#item_'+id, 'item_'+id, id, 'step_2_selected', 'step2_category_selected',true,'check_next_button(2);potential_match(2); show_select_all(\'#item_'+id+'\',true); /*_kmq.push([\'record\', \'onboarding x button removes things you like\',{ \'SignedIn\' : get_KMSignedIn()}]); _gaq.push([\'_trackEvent\', \'onboarding\', \'Clk_removesubcat\', \'Clicks to Remove On Any Items In Things You Want\']);*/');
            show_select_all('#item_'+id);
        }
        if (s_img.length > 0)
        {
            var result = s_img.split('##');
            if (result[1] == 'img')
            {
                $('#step2_potential_match_img > img').attr('src',result[0]);
                $('#step2_potential_match_img').show();
                $('#itemPlayer_step2').hide();
            }
            else if (result[1] == 'video')
            {
                playVideo('itemPlayer_step2', result[0], false, null);
                $('#itemPlayer_step2').css('display','block');
                $('#step2_potential_match_img').hide();
            }
            $('#step2_no_potential_match').hide();
        }
    }
    // show user's selected interests
    if (user_interests_ids.length > 0)
    {
        selected_ids = user_interests_ids.split(',');
        for(index = 0; index < selected_ids.length; index++)
        {
            id = selected_ids[index]
            selectMultipleCategory('#item_'+id, 'item_'+id, id, 'step_3_selected', 'step3_category_selected',true,'check_next_button(3);potential_match(3);show_select_all(\'#item_'+id+'\',true); /*_kmq.push([\'record\', \'onboarding x button removes your interests\',{ \'SignedIn\' : get_KMSignedIn()}]); _gaq.push([\'_trackEvent\', \'onboarding\', \'Clk_removesubcat\', \'Clicks to Remove On Any Items In Your Interests\']);*/');
            show_select_all('#item_'+id);
        }
        if (i_img.length > 0)
        {
            var result = i_img.split('##');
            if (result[1] == 'img')
            {
                $('#step3_potential_match_img > img').attr('src',result[0]);
                $('#step3_potential_match_img').show();
                $('#itemPlayer_step3').hide();
            }
            else if (result[1] == 'video')
            {
                playVideo('itemPlayer_step3', result[0], false, null);
                $('#itemPlayer_step3').css('display','block');
                $('#step3_potential_match_img').hide();
            }
            $('#step3_no_potential_match').hide();
        }
    }
    // show user's wish
    $('#step3_user_wish').val(user_wish);
    // enable/disable next buttons of 3 stages
    check_next_button(1);
    check_next_button(2);
    check_next_button(3);
    // show the required step
    $('.step1').hide();
    $('.step2').hide()
    $('.step3').hide();
    $('.step' + step).show();

}

function check_next_button(step)
{
    var selected_values = $('#step_' + step + '_selected').val();
    if (selected_values.split(',').length > 2)
    {
        $('#next_disabled_step_' + step).hide();
        $('#next_enabled_step_' + step).show();
        $('#save_disabled_step_' + step).hide();
        $('#save_enabled_step_' + step).show();
        $('#error_message_step_' + step).hide();
    }
    else
    {
        $('#next_disabled_step_' + step).show();
        $('#next_enabled_step_' + step).hide();
        $('#save_disabled_step_' + step).show();
        $('#save_enabled_step_' + step).hide();
        $('#error_message_step_' + step).show();
    }
}
var searchField = null;
var searchFieldClass = null;
function search(i, cls){
    searchField = i;
    searchFieldClass = cls;
    var t = $(i).val();
    var found = false;
    if(t == ""){
        $('li.' + cls + '[tag]').each(function(index) {
            if(!$(this).hasClass('categoryselected')){
                $(this).show();
                found = true;
            }
        });
    }else{
        $('li.' + cls + '[tag]').each(function(index) {
            $(this).hide();
        });
        $('li.' + cls + '[tag*=' + (t.length > 0 ? '"' + t.toLowerCase() + '"' : '') + ']').each(function(index) {
            if(!$(this).hasClass('categoryselected')){
                $(this).show();
                found = true;
            }
        });
    }
    if(!found){
        $('li.' + cls + '[tag=noresultmatch]').text('No results match "' + t + '"');
        $('li.' + cls + '[tag=noresultmatch]').show();
    }else{
        $('li.' + cls + '[tag=noresultmatch]').hide();
    }
}

function reset_search_text(id, cls)
{
    input_field = $('#'+id);
    input_field.val('');
    search(input_field, cls);
}

function custom_scroll(divId){
    if (!$('#' + divId).hasClass('mCustomScrollbar')) $('#' + divId).mCustomScrollbar({scrollInertia:0, advanced:{updateOnContentResize: true}});
}

function submit_thumbs_down_feedback()
{
    if ($('#thumb_feedback_id').val().length > 0)
    {
        var id = $('#thumb_feedback_id').val();
        var option = $('input[name=thumbdown_item]:radio:checked').val()
        var comment = $('#thumb_down_comment').val();
        if ((id.length > 0) && (option.length > 0 ))
        {
            jQuery.ajax({
                type: "POST",
                url: "/thumbs_down_feedback",
                data: "id=" + id +"&option=" + option + "&comment=" + encodeURIComponent(comment) + "&authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()),
                success: function(msg, status, xhr){
                    // alert("success");
                    $('#thumb_feedback_id').val('');
                    // hideModal('thumb_down');
                    $('#thumb_down').modal('hide');
                },
                error: function(xhr, status){
                    alert("error");
                }
            });

        }

        // reset the values
    }
}

function suggest_new_sub_category(parent_name,category_id,category_name)
{
    $('.suggest_cat_drpdown').removeClass('selected_dropdown');
    $('#' + parent_name + '_category').addClass('selected_dropdown');
    $('#selected_category').text(category_name);
    $('#selected_category_id').val(category_id);
    $('#error_message_select_cat').hide();
    $("#suggest_cat_dropdown_box").hide();
    $("#suggest_cat_resultdiv").hide();
    $('#ul_suggest_cat_list').empty();
    $('#suggest_cat_spinner').hide();
    $('#new_cat_text').val('Your Most Awesome New Sub-Category...');
    // showModal('suggest_cat');
    $('#suggest_cat').modal('show');
}

function submit_new_category()
{
    var suggestion = $('#new_cat_text').val();
    if (suggestion == '' || suggestion == "Your Most Awesome New Sub-Category..." )
        $('#error_message_select_cat').show();
    else
    {
        jQuery.ajax({
            type: "POST",
            url: "/suggest_new_category",
            data: "parent_id=" + $('#selected_category_id').val() +"&suggestion=" + encodeURIComponent(suggestion) + "&authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()),
            success: function(msg, status, xhr){
                // hideModal('suggest_cat');
                // showModal('thnx_cat');
                $('#suggest_cat').modal('hide');
                $('#thnx_cat').modal('show');
            },
            error: function(xhr, status){
                alert("error");
            }
        });

    }

}

var lockSuggestCatAjaxCall=false;
var otSuggestCatAjaxSearch='';
function search_suggested_cat(e){
    if (e.preventDefault) { e.preventDefault(); } else { e.returnValue = false; }
    if (e.keyCode == 13) { // No need to do browser specific checks. It is always 13.
        jQuery('#suggest_cat_spinner').hide();
        jQuery("#suggest_cat_dropdown_box").hide();
        jQuery("#suggest_cat_resultdiv").hide();
        return false;
    }
    if(jQuery("#new_cat_text").val().length > 0 && (e.which != 27) && (e.which != 38)){
        if (lockSuggestCatAjaxCall == true && otSuggestCatAjaxSearch != ""){
            otSuggestCatAjaxSearch.abort();
            lockSuggestCatAjaxCall = false;
        }
        jQuery('li.li_cat_title').remove();
        jQuery('#ul_suggest_cat_list').empty();
        jQuery('#suggest_cat_spinner').show();
        jQuery("#suggest_cat_dropdown-body").css('height','11px');
        jQuery("#suggest_cat_dropdown_box").show();
        jQuery("#suggest_cat_resultdiv").hide();
        otSuggestCatAjaxSearch = jQuery.ajax({
            cache: true,
            url: "/search_similar_categories?value=" + encodeURIComponent(jQuery("#new_cat_text").val()) + "&category_id=" + jQuery('#selected_category_id').val(),
            beforeSend: function ( xhr ) {
                lockSuggestCatAjaxCall = true;
            },
            success: function(data){
                if(data == "[]"){
                    jQuery('#ul_suggest_cat_list').empty();
                    jQuery("#suggest_cat_dropdown_box").hide();
                    jQuery('#suggest_cat_spinner').hide();
                }else{
                    jQuery('#ul_suggest_cat_list').empty();
                    jQuery('#suggest_cat_spinner').hide();
                    result = jQuery.parseJSON(data);
                    if (result.length < 5){
                        jQuery("#suggest_cat_dropdown-body").css('height', result.length*22+'px');
                        jQuery("#suggest_cat_dropdown-body").css('overflow-y','visible');
                    }else{
                        jQuery("#suggest_cat_dropdown-body").css('height','80px');
                        jQuery("#suggest_cat_dropdown-body").css('overflow-y','auto');
                    }

                    var ni = document.getElementById('ul_suggest_cat_list');
                    for (i=0;i<result.length;i++){
                        var newdiv = document.createElement('li');
                        dspname = "";
                        dspname = result[i];
                        newdiv.setAttribute('id', 'ot_'+i);
                        newdiv.setAttribute('style', 'cursor:pointer');
                        newdiv.setAttribute('onKeyDown', "updowntop('ot_"+i+"',event);");
                        newdiv.setAttribute('onclick', "search_cat_select('" + dspname + "');");
                        newdiv.setAttribute('onfocus', "$('.li_cat_title').css('background-color','#fff');$(this).css('background-color','#ccc')");
                        newdiv.setAttribute('onmouseover', "$(this).focus();");
                        newdiv.setAttribute('class', "li_cat_title");
                        newdiv.innerHTML = "<a style='text-decoration:none; color: #777;font-size: 13px;' href=\"#\" onclick=\"return false;search_cat_select(\'" + dspname + "\');\">"+dspname+"</a>";
                        ni.appendChild(newdiv);
                    }
                    jQuery('#suggest_cat_spinner').hide();
                    jQuery("#suggest_cat_resultdiv").show();
                }
            },
            complete: function(){
                lockSuggestCatAjaxCall = false;
            }
        });
    }else{
        jQuery('#suggest_cat_spinner').hide();
        jQuery("#suggest_cat_dropdown_box").hide();
        jQuery("#suggest_cat_resultdiv").hide();
    }
}

function search_suggest_down(event){
    if (event.keyCode == 40){
        if (event.preventDefault) { event.preventDefault(); } else { event.returnValue = false; }
        $("#ul_suggest_cat_list li a:first").focus();
    }
    return false;
}

function search_cat_updowntop(id, event){
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
            if (idStr[0] == "ot"){$("#new_cat_text").focus();}
        }else{
            idStr[1] = parseInt(idStr[1])-1
            $("#"+idStr[0]+"_"+idStr[1]+" a").focus();
        }
    }
    return false;
}

function search_cat_select(value)
{
    jQuery("#new_cat_text").val(value);
    jQuery("#suggest_cat_dropdown_box").hide();
    jQuery("#suggest_cat_resultdiv").hide();
}

function show_promote_tradeya(id){
    isPromoteTradeya = false;
    jQuery.ajax({
        url: "/is_signed_in",
        success: function(data){
            if(data == "true"){
                jQuery.ajax({
                    url: "/is_pub?id="+id,
                    success: function(data){
                        if(data == "true") openPromoteNowPopup(id);
                    }
                });
            }else{
                isPromoteTradeya = true;
                openLoginForm();
            }
        }
    });
}

function show_onboarding(){
    showOnboarding = false;
    jQuery.ajax({
        url: "/is_signed_in",
        success: function(data){
            if(data == "true"){
                window.location = '/profile';
            }else{
                showOnboarding = true;
                openLoginForm();
            }
        }
    });
    return false;
}

searching_potential_match = false;
function potential_match(step)
{
    if(searching_potential_match)
        return;
    searching_potential_match = true;
    sub_cat_ids = $('#step_'+step+'_selected').val();
    if (sub_cat_ids.length <= 0)
    {
        $('#step'+step+'_potential_match_img').hide();
        $('#itemPlayer_step'+step).hide();
        $('#step'+step+'_no_potential_match').show();
    }
    else
    {
        jQuery.ajax({
            url: "/search_potential_match",
            data: "step="+step+"&sub_cat_ids="+encodeURIComponent(sub_cat_ids)+ "&authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()),
            success: function(data){
                if (data == "error"){
                    location.reload(true);
                    return;
                }
                if(data.length > 0)
                {
                    var result = data.split('##');
                    if (result[1] == 'img')
                    {
                        $('#step'+step+'_potential_match_img > img').attr('src',result[0]);
                        $('#step'+step+'_potential_match_img').show();
                        $('#itemPlayer_step'+step).hide();
                    }
                    else if (result[1] == 'video')
                    {
                        $('#itemPlayer_step'+step).css('display','block');
                        playVideo('itemPlayer_step'+step, result[0], false, null);
                        $('#step'+step+'_potential_match_img').hide();
                    }
                    $('#step'+step+'_no_potential_match').hide();
                }
            },
            error: function(xhr, status){
                alert("error");
            }
        })
    }
    searching_potential_match =false;
}

function select_all_drpdwns(drp_dwn_id)
{
    // to avoid running potential match search on selection of every item
    searching_potential_match =true;
    var lis = $('#'+drp_dwn_id).find('li');
    for(var i=1; i<lis.length-1;i++)
    {
        var li = lis[i];
        if(!($(li).hasClass('categoryselected')))
        {
            $(li).click();
        }
    }
    $(lis[0]).addClass('hidedrop');
    searching_potential_match = false;
}

function show_select_all(item_obj, always_show)
{
    var lis = $(item_obj).siblings();
    if((typeof(always_show) != 'undefined') && (always_show == true))
    {
        $(lis[0]).removeClass('hidedrop');
        return;
    }
    for(var i=1; i<lis.length-1;i++)
    {
        var li = lis[i];
        if(!($(li).hasClass('categoryselected')))
        {
            $(lis[0]).removeClass('hidedrop');
            return;
        }
    }
    $(lis[0]).addClass('hidedrop');
}

function hide_select_all(txtbox_id, li_id)
{
    if($('#'+txtbox_id).val().length > 0 )
        $('#'+li_id).addClass('hidedrop');
    else
        $('#'+li_id).removeClass('hidedrop');
}

// To record SingedIn property with every event in KissMetrics
function set_KMSignedIn_true()
{
    KM_SignedIn = true;
}

function get_KMSignedIn()
{
    return String(KM_SignedIn);
}


function set_isGuest_true()
{
    isGuest = true;
}

function guest_user_final_signup(token)
{
    if(typeof(token)=='undefined'){ token = ""; }
    jQuery.ajax({
        url: "/getUserData.js",
        data: "guest_sign_up=true"+((token.length>0)?"&guest_token="+token:"")+"&authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()),
        success: function(data){
            // alert("success");
            // if (data == "error"){
            //  location.reload(true);
            //  return;
        },
        error: function(data){
            // alert("error");
        }
    });
}

// To show hello modal after 3 minutes
// function hello_modal_timer_check(reset){
//      if(typeof(reset)=='undefined'){ reset = ""; }
//      jQuery.ajax({
//              url: "/hello_modal_timer",
//              data: ((reset.length>0)?"reset="+reset+"&":"")+"authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()),
//              success: function(data){
//                      if (data != "ok"){
//                              var t = data.split(",")[0];
//                              var m = data.split(",")[1];
//                              if (t > 0)
//                              {
//                                      setTimeout(function() { hello_modal_timer_show(m);}, t*1000); }
//                              else
//                              { hello_modal_timer_show(m); }
//                      }
//              },
//              error: function(data){
//                      // alert("error");
//              }
//      });
// }

// function hello_modal_timer_show(modal){
//      // commented for quiz
//      // m = ((modal==2)? "hello_modal_new" : "hello_modal");
//      m = "quiz_box";

//      if( !(KM_SignedIn) || (KM_SignedIn && isGuest)){
//              // hideModal("");
//              // showModal(m);
//              $('.modal.in').modal('hide');
//              $('#'+ m).modal('show');
//              isQuiz = true;
//      }

//              // _kmq.push(['record', 'hello modal pop-up after 3 mins',{ 'SignedIn' : get_KMSignedIn(), 'HelloModal' : ((modal==2)? 'new' : 'old')}]);

//      jQuery.ajax({
//              url: "/hello_modal_timer",
//              data: "stop=true&authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()),
//              success: function(data){
//              },
//              error: function(data){
//              }
//      });
// }

function ZipEnter(event){
    if (event.keyCode == 13) {
        event.preventDefault();
        validate_zip();
    }
}

function validate_zip(){
    var intRegex = /^\d+$/;
    if(jQuery('#zip').val() == ""){
        $('.edit_loc_wrapper').css('height','85px');
        jQuery('#error_zip').text('City or Zip Code should not be empty');
    }else if(jQuery('#zip').val().match(intRegex) == null){
        $('.edit_loc_wrapper').css('height','65px');
        jQuery('#error_zip').text('zip code format not valid.');
    }else{
        // _kmq.push(['record', 'modal edit zip save button',{ 'SignedIn' : get_KMSignedIn()}]);
        // _gaq.push(['_trackEvent', 'modal', 'Clk_ChangeLocationBtn', 'clicks on save button in Change location Modal'])
        $('#change_location').submit();
    }
}

function validateReview(e,submit_btn)
{
    var form = $(submit_btn).parents('form');
    form.find('.error_explanation').addClass('hidedrop');
    if (form.find('#review_title').val().length <= 0)
        form.find('#title_error').removeClass('hidedrop');
    else if(form.find('#review_review_text').val().length <= 0)
        form.find('#review_error').removeClass('hidedrop');
    else if(form.find("input[name='review[describe_rating]']").val().length <= 0)
        form.find('#desc_rating_error').removeClass('hidedrop');
    else if(form.find("input[name='review[communication_rating]']").val().length <= 0)
        form.find('#comm_rating_error').removeClass('hidedrop');
    else
    { return true; }
    e.preventDefault();
    return false;
}

function cancelReview(cancel_btn)
{
    var form = $(cancel_btn).parents('form');
    form.find('.error_explanation').addClass('hidedrop');
    form.find('#review_title').val('');
    form.find('#review_review_text').val('');
    form.find('.star_rating_large.item_described').raty('cancel', false);
    form.find('.star_rating_large.item_communication').raty('cancel', false);
    return
}

// Code to close dropdowns on clicking anywhere on the document start
function closeChangeLocation(){
    $(".change_loc").removeClass("change_loc_selected")
    $(".change_loc").siblings(".edit_loc_wrapper").removeClass("show_locs");
    return false;
}

function closeCategoriesDropdown(){
    $('#category_dropdown').hide();
    $('#category_drpdwn_txt').removeClass('category_drpdown_selected');
    $('#category_drpdwn_txt').removeClass('top_cat_selected');
}

function closeUserOptions(){
    $(".user_options").removeClass("show");
}

$(function(){
    $(document).click(function(){
        closeChangeLocation();
        closeCategoriesDropdown();
        closeUserOptions();
    });
    $("#category_dropdown_section").click(function(e){
        e.stopPropagation();
        closeChangeLocation();
        closeUserOptions();
    });
    $("#change_location_section").click(function(e){
        e.stopPropagation();
        closeCategoriesDropdown();
        closeUserOptions();
    });
    $("#user_img_top").click(function(e){
        e.stopPropagation();
        closeChangeLocation();
        closeCategoriesDropdown();
    });
})

// Code to close dropdowns on clicking anywhere on the document finish

function closeWantsMessages(){
    $("#want_message_modal").modal("hide");
    $('.want_message_div').hide();
    return false;
}

function closeLoginForm(){
    $('#signin_modal').modal('hide');
}
function openLoginForm(){
    $('#signup_box').modal('hide');
    $('#signin_modal').modal('show');
}

var friends_search_requestXHR;
function search_friends(id)
{
    // alert("search_friends");
    if(typeof(friends_search_requestXHR) != "undefined")
        if(friends_search_requestXHR.readystate != 4)
            friends_search_requestXHR.abort();
            $('#spinner').show();
            $('.follow_tab_div_overlay').show();
    friends_search_requestXHR = $.ajax({
        type: "get",
        url: "/users/" + id + "/following_tab_search",
        dataType: "script",
        data: {search_user: $("#search_user").val()},
        success: function(data){
            $('#spinner').hide();
            $('.follow_tab_div_overlay').hide();
        },
    });
    return false;
}

function clickcross(){
    $("#search_user").val("");
    $('.search_cross').hide();
    $("#searched_users").hide();
    // $("#facebook_friends").hide();
    // $("#twitter_friends").hide();
    $("#followed_friends").show();
    return false;
};

function popitup(url){
    newwindow=window.open(url,'name','height=350,width=800');
    if (window.focus) {newwindow.focus()}
    return false;
}
function launchEditor(id,src) {
   featherEditor.launch({
       image: id,
       url: src
   });
   $("#custom_backdrop").show();
  return false;
}

function get_shipping(){
    var tradeid = $("#getShippingSubmit").attr('tradeid');
    // alert($('#transaction_weight').val());
    // alert($('#transaction_length').val());
    $('#items_spinner').show();

    //alert(tradeid);
    $("#package-details-form").find("#error_explanation").text("");
    if($("#package-details-form").find("#transaction_weight").val() == "")
        $("#package-details-form").find("#error_explanation").text("Weight cannot be empty");
    else if($("#package-details-form").find("#transaction_length").val() == "")
        $("#package-details-form").find("#error_explanation").text("Length cannot be empty");
    else if($("#package-details-form").find("#transaction_width").val() == "")
        $("#package-details-form").find("#error_explanation").text("Width not be empty");
    else if($("#package-details-form").find("#transaction_height").val() == "")
        $("#package-details-form").find("#error_explanation").text("Height cannot not be empty");
    else {
        jQuery.ajax({
            type: "POST",
            // url: "/trades/" + trade_id + "/transactions",
            url: "/transactions/get_shipping",
            dataType:"json",
            //url: $(location).attr('pathname'),
            data: "trade_id=" + tradeid + "&weight=" + jQuery('#transaction_weight').val() + "&length=" + jQuery('#transaction_length').val() + "&width=" + jQuery('#transaction_width').val() + "&height=" + jQuery('#transaction_height').val() + "&authenticity_token=" + encodeURIComponent($("#signInForm input[name=authenticity_token]").val()),
            success: function(ups_rates){
                // showModal('msg_sent');
                 $('#shipping_rates').empty();
                $.each(ups_rates,function(i,upsrates){
                    // alert(upsrates.service_name)
                    // if('#shipping_rates')
                    $('#shipping_rates').append('<input id=' + 'shipping' + upsrates.service_code + ' '  + 'name="shipping" type="radio" value="' + upsrates.service_name + ',' + upsrates.price + ',' + upsrates.service_code  + '"><label for='+ 'shipping' + upsrates.service_code +'>'+ upsrates.service_name + '($' + upsrates.price + ')'  +'</label>');
                });
                // alert("hello");
                // alert(ups_rates);
                // $('#msg_sent').modal('show');

                $('.length_input').prop("readonly",true);
                $('#controlgroup1 a').remove();
                $('#controlgroup1').prepend('<a id="edit_ship_details" onclick="edit_ship_details()" style="float:right;font-size:12px;cursor:pointer">Edit Details</a>');
                $('.length_input').on("change",function(){
                        $('#shipping_rates').empty();
                        //alert("You'll have to recalculate shipping rates");
                });


                $('#items_spinner').hide();
            },
            error: function(xhr, status){alert("unable to send");}

        });
    // return false;
    }
}

function edit_ship_details(){
    
        $('.length_input').prop("readonly",false);
        $('#shipping_rates').empty();
        $('#edit_ship_details').hide();
   // });
}
