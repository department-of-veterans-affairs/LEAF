workflowStepModule[{{$stepID}}] = workflowStepModule[{{$stepID}}] || {};
workflowStepModule[{{$stepID}}]['UNIQUE_NAME_OF_MODULE'] = (function() {

	function init(recordID, rootURL) {

	}

	/* if multiple modules exist for a specific step, the system will iterate through
		all modules and only execute the first trigger encountered
	*/
	function trigger(callback) {
		callback();
	}

	return {
		init: init,
		trigger: trigger
	};
})();
