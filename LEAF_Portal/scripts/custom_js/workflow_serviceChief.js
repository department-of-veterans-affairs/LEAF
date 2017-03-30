workflowModule[1] = (function() {
	var prefixID = 'workflowModule' + Math.floor(Math.random()*1000) + '_';
	var depID = 1;
	var indicatorID = 16;
	var series = 1;
	var form;

	function init(recordID) {
		$('#form_dep_extension' + depID).html('<div style="padding: 8px">\
				<div style="background-color: white; border: 1px solid black; padding: 4px">\
					<div id="'+prefixID+'container"></div>\
					<div id="'+prefixID+'anchor"></div>\
				</div>\
				</div>');

		form = new LeafForm(prefixID + 'anchor');
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