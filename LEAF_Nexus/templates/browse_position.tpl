<div id="maincontent">
    <div id="position">
        <div id="positionHeader">
            <span id="positionTitle">Position Search:</span>
        </div>
        <div id="positionBody" style="width: 99%">
                <div id="positionSelector"></div>
        </div>
    </div>
</div>

<div id="orgchartForm"></div>

<script type="text/javascript">
/* <![CDATA[ */

var posSel;
var intval;
$(function() {
	posSel = new positionSelector('positionSelector');
	posSel.initialize();
	posSel.enableNoLimit();

	posSel.setSelectHandler(function() {
    	window.location = '?a=view_position&positionID=' + posSel.selection;
    });

    orgchartForm = new orgchartForm('orgchartForm');
    orgchartForm.initialize();

});

/* ]]> */
</script>