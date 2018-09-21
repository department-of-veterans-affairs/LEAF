<div style="background-color: #d76161; padding: 8px; margin: 0px; color: white; text-shadow: black 0.1em 0.1em 0.2em; font-weight: bold; text-align: center; font-size: 120%">Please review your request before submitting</div>

<div style="width: 500px; background-color: white; border: 1px solid #0000005c; padding: 8px; margin: auto;">
	<link type="text/css" rel="stylesheet" href="{$orgchartPath}/css/employeeSelector.css">
	<link type="text/css" rel="stylesheet" href="{$orgchartPath}/css/groupSelector.css">
	<script type="text/javascript" src="{$orgchartPath}/js/nationalEmployeeSelector.js"></script>
	<script type="text/javascript" src="{$orgchartPath}/js/groupSelector.js"></script>
    <script type="text/javascript" src="js/parallelProcessing.js"></script>
    <script type="text/javascript">
        selectForParallelProcessing({$recordID}, "{$orgchartPath}");
    </script>

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
    <button class="buttonNorm" type="button" style="font-weight: bold; font-size: 120%" onclick="doSubmitForParallelProcessing({$recordID|strip_tags}, selectForParallelProcessing.buildParallelProcessingDataJSON());"><img src="../libs/dynicons/?img=go-next.svg&amp;w=32" alt="Submit" />Begin Parallel Processing</button>
</div>