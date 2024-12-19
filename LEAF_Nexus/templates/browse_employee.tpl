<div id="toolbar" class="toolbar_right toolbar noprint">
    <div id="tools" style="visibility: hidden"><h1>Tools</h1>
        <div onclick="alert('Not implemented yet');"><img src="dynicons/?img=emblem-train.svg&amp;w=32" style="vertical-align: middle" alt="" /> Request Travel/Training</div>
        <div onclick="alert('Not implemented yet');"><img src="dynicons/?img=car.svg&amp;w=32" style="vertical-align: middle" alt="" /> Request Govt. Vehicle</div>
        <div onclick="alert('Not implemented yet');"><img src="dynicons/?img=emblem-parking.svg&amp;w=32" style="vertical-align: middle" alt="" /> Request Parking Decal</div>
        <div onclick="alert('Not implemented yet');"><img src="dynicons/?img=award-ribbon.svg&amp;w=32" style="vertical-align: middle" alt="" /> Recommend for Award</div>
    </div>
</div>

<div id="maincontent">
    <div id="employee">
        <div id="employeeHeader">
            <span id="employeeName">Employee Search:</span>
        </div>
        <div id="employeeBody">
                <div id="employeeSelector"></div>
        </div>
    </div>
</div>

<div id="orgchartForm"></div>
<!--{include file="site_elements/generic_xhrDialog.tpl"}-->

<script type="text/javascript">
/* <![CDATA[ */

<!--{include file="site_elements/genericJS_toolbarAlignment.tpl"}-->

var empSel;
var intval;
$(function() {
    empSel = new employeeSelector('employeeSelector');
    empSel.initialize();
    empSel.enableNoLimit();

    empSel.setSelectHandler(function() {
        window.location = '?a=view_employee&empUID=' + empSel.selection;
    });
});

/* ]]> */
</script>
