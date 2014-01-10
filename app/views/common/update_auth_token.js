$('input[name=authenticity_token]').each(function(){
	$(this).val('<%= form_authenticity_token %>');
});