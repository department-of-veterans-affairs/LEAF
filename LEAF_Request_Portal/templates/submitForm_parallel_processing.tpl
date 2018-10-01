<link type="text/css" rel="stylesheet" href="{$orgchartPath}/css/employeeSelector.css">
<link type="text/css" rel="stylesheet" href="{$orgchartPath}/css/groupSelector.css">
<style type="text/css">
	.ui-widget-header {
		background: #cedc98;
		border: 1px solid #DDDDDD;
		color: #333333;
		font-weight: bold;
	}
</style>
<script type="text/javascript" src="{$orgchartPath}/js/nationalEmployeeSelector.js"></script>
<script type="text/javascript" src="{$orgchartPath}/js/groupSelector.js"></script>
<script type="text/javascript" src="js/lz-string/lz-string.min.js"></script>
<script type="text/javascript" src="js/parallelProcessing.js"></script>
<script type="text/javascript">
	selectForParallelProcessing({$recordID}, "{$orgchartPath}", "{$CSRFToken}", "{$categoryID}");
	$('#pp_progressBar').progressbar();
	$('#pp_progressBar').progressbar('option', 'value', 0);
	$('#pp_progressLabel').text('0%');
</script>
<div id="pp_banner" style="background-color: #d76161; padding: 8px; margin: 0px; color: white; text-shadow: black 0.1em 0.1em 0.2em; font-weight: bold; text-align: center; font-size: 120%">Please review your request before submitting</div>
<div id="pp_selector" style="width: 500px; background-color: white; border: 1px solid #0000005c; padding: 8px; margin: auto;">
	<div id="selectDiv" style="">Please select an indicator:<br>
		<select id="indicator_selector">
			<option value="0-0">-Select-</option>
		</select>
		<div style="visiblity: hidden; display: none" class="emp_visibility">
			<div id="empSelector"></div><br>
			<span>Hint: If there are too many results, use their E-mail address as a search term.</span>
		</div>
		<div style="visiblity: hidden; display: none" class="grp_visibility">
			<div id="grpSelector"></div>
		</div>
		<div style="text-align: left;">
			<h4 style="visiblity: hidden; display: none" class="emp_visibility">Selected Employee(s):</h4>
			<ul style="visiblity: hidden; display: none" class="emp_visibility id_selections" id="selectedEmployeeList">
			</ul>
			<h4 style="visiblity: hidden; display: none" class="grp_visibility">Selected Group(s):</h4>
			<ul style="visiblity: hidden; display: none" class="grp_visibility  id_selections" id="selectedGroupList">
			</ul>
		</div>
	</div>
</div>
<div style="padding: 8px; width: 260px; margin: auto" id="submitControl">
    <button class="buttonNorm" type="button" style="font-weight: bold; font-size: 120%" ><img src="../libs/dynicons/?img=go-next.svg&amp;w=32" alt="Submit" />Begin Parallel Processing</button>
</div>
<div id="pp_progressSidebar" style="display: none;">
        <div style="padding: 8px; margin: 0px; color: black; font-weight: bold; text-align: center; font-size: 120%"><img src="./images/indicator.gif" />Submitting</div>
        <div id="pp_progressControl" style="padding: 0 16px 16px; text-align: center; background-color: #ffaeae; font-weight: bold; font-size: 120%"><div id="pp_progressBar" style="height: 30px; border: 1px solid black; text-align: center; width: 80%; margin: auto"><div style="width: 100%; line-height: 200%; float: left; font-size: 14px" id="pp_progressLabel"></div></div><div style="line-height: 30%"><!-- ie7 workaround --></div></div>
</div>