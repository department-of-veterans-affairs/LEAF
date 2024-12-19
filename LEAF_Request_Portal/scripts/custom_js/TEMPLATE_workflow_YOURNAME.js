var workflowModule_[dependencyID] = (function() {
	function init() {
		$('#form_dep_extension' + dependencyID).html('<div style="padding: 4px">\
				<div style="background-color: white; border: 1px solid black; padding: 4px">test</div>\
				</div>');		
	}

	function trigger() {
		
	}

	return {
		init: init,
		trigger: trigger
	};
}());