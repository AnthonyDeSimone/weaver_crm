var jsony;


$(document).ready(function(){
	// select2 customer selection //
	$("#customerSelect").select2({
		ajax: {
			url: "http://76.115.226.174" + "/customers/search",
			dataType: 'jsonp',
			delay: 250,
			data: function (params) {
				return {
					q: params.term, // search term
					page: params.page
				};
			},
			processResults: function (data, page) {
				// parse the results into the format expected by Select2.
				// since we are using custom formatting functions we do not need to
				// alter the remote JSON data
				return {
					results: data.items
				};
			},
			cache: true
		},
		minimumInputLength: 1,
	});
	
	$("#foo").click(function() {
		loadOrder(JSON.parse($("#blah").val()), function(status) {
			var reasons = "";
			for (var i = 0; i < status.reason.length; i++) reasons += (i+1) + ": " + status.reason[i] + "\n";
			$("#blah").val(
				"Error: " + status.error + "\n" + reasons
			);
		});
	});
	$("#bar").click(function() {
		var scope = angular.element($("#main")).scope();
		scope.$apply(function() {
			jsony = JSON.stringify(scope.form.getSaveObject());
			$("#blah").val(jsony);
		});
	});
	$("#blah").click(function() {
		$("#blah").select();
	});
});
