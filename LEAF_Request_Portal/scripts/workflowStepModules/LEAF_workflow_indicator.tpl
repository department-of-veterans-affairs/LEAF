workflowStepModule[{{$stepID}}] = workflowStepModule[{{$stepID}}] || {};
workflowStepModule[{{$stepID}}]['LEAF_workflow_indicator'] = (function() {
	var prefixID = 'workflowStepModule' + Math.floor(Math.random()*1000) + '_';
	var depID = null;
	var config = JSON.parse('{{$moduleConfig}}');
	var series = 1;
	var form;

	function init(step, rootURL) {
		recordID = step.recordID;
		depID = step.dependencyID;
		indicatorID = config.indicatorID;
		$('#form_dep_extension' + depID).html('<div style="padding: 8px 24px 8px">\
				<div style="background-color: white; border: 1px solid black; padding: 16px">\
					<div id="'+prefixID+'container"></div>\
					<div id="'+prefixID+'anchor"></div>\
				</div>\
				</div>');

		form = new LeafForm(prefixID + 'anchor');
        form.setRootURL(rootURL);
		form.initCustom(prefixID + 'anchor', prefixID + 'container', prefixID + 'anchor', prefixID + 'anchor', prefixID + 'anchor');
		form.setHtmlFormID('form_dep'+ depID);
		form.setRecordID(recordID);
		form.getForm(indicatorID, series);
	}

	function trigger(callback) {
		if(callback != undefined) {
			form.setPostModifyCallback(callback);
		}
		form.dialog().clickSave();
	}

	return {
		init: init,
		trigger: trigger
	};
})();
