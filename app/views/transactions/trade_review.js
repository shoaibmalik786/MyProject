$("#trade_review").html("<%= raw escape_javascript(render 'transactions/partials/trade_review') %>");
$('input.card_select').prop('disabled',true)
$('#cards_div_step').hide();
$('#add_card').hide();