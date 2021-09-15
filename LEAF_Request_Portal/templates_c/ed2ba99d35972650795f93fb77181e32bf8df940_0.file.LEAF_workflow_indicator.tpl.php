<?php
/* Smarty version 3.1.33, created on 2021-08-04 15:19:33
  from '/var/www/html/LEAF_Request_Portal/scripts/workflowStepModules/LEAF_workflow_indicator.tpl' */

/* @var Smarty_Internal_Template $_smarty_tpl */
if ($_smarty_tpl->_decodeProperties($_smarty_tpl, array (
  'version' => '3.1.33',
  'unifunc' => 'content_610ab005659fc8_01315109',
  'has_nocache_code' => false,
  'file_dependency' => 
  array (
    'ed2ba99d35972650795f93fb77181e32bf8df940' => 
    array (
      0 => '/var/www/html/LEAF_Request_Portal/scripts/workflowStepModules/LEAF_workflow_indicator.tpl',
      1 => 1626204510,
      2 => 'file',
    ),
  ),
  'includes' => 
  array (
  ),
),false)) {
function content_610ab005659fc8_01315109 (Smarty_Internal_Template $_smarty_tpl) {
?>workflowStepModule[<?php echo $_smarty_tpl->tpl_vars['stepID']->value;?>
] = workflowStepModule[<?php echo $_smarty_tpl->tpl_vars['stepID']->value;?>
] || {};
workflowStepModule[<?php echo $_smarty_tpl->tpl_vars['stepID']->value;?>
]['LEAF_workflow_indicator'] = (function() {
	var prefixID = 'workflowStepModule' + Math.floor(Math.random()*1000) + '_';
	var depID = null;
	var config = JSON.parse('<?php echo $_smarty_tpl->tpl_vars['moduleConfig']->value;?>
');
	var series = 1;
	var form;

	function init(step) {
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
})();<?php }
}
