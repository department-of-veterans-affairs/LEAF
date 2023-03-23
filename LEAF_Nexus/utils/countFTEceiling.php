<!DOCTYPE html>
<html>
<head>
        <title>Organizational Chart Utility - Count FTE Ceiling</title>
        <style type="text/css" media="screen">
                @import "../../libs/js/jquery/css/dcvamc/jquery-ui.custom.min.css";
        @import "../../libs/js/jquery/chosen/chosen.min.css";
                @import "../css/style.css";
        @import "../css/editor.css";
        @import "../css/positionSelector.css";
    </style>
    <style type="text/css" media="print">
        @import "../css/printer.css";
        @import "../css/editor_printer.css";
    </style>
        <script type="text/javascript" src="../../libs/js/jquery/jquery.min.js"></script>
        <script type="text/javascript" src="../../libs/js/jquery/jquery-ui.custom.min.js"></script>
        <script type="text/javascript" src="../../libs/js/jquery/chosen/chosen.jquery.min.js"></script>
    <script type="text/javascript" src="../js/positionSelector.js"></script>
    <link rel="icon" href="vafavicon.ico" type="image/x-icon" />
</head>
<body>
<span style="font-size: 120%">This utility will count the FTE ceiling for a position and it's subordinates.</span><br /><br />
<div style="width: 40%; padding: 8px">Search Position or Name of Employee:
     <div id="position"></div>
</div>
<div style="padding: 8px">
<fieldset>
    <legend>Stats</legend>
    <span id="result"></span>
</fieldset>
</div>
<div style="padding: 8px">
<fieldset>
    <legend>Errors - Note: Links will open a new window</legend>
    <span id="errors"></span>
</fieldset>
</div>

<script type="text/javascript">
/* <![CDATA[ */

function add(a, b) {
	return Math.round((parseFloat(a) + parseFloat(b)) * 100)/100;
}

function logError(error) {
    $('#errors').html($('#errors').html() + error + '<br />');
}

var fteTotal = 0;
var fteCurrent = 0;
function countFTE(positionID) {
    $.get('../api/position/' + positionID,
        function(data) {
            if($.isNumeric(data[11].data)) {
                fteTotal = Math.round((parseFloat(data[11].data) + fteTotal) * 100)/100;
            }
            else {
                logError('Missing FTE Ceiling - <a href="../?a=view_position&positionID=' + positionID + '" target="_blank">'+ data.title + '</a>');
            }
            if($.isNumeric(data[17].data)) {
            	fteCurrent = add(data[17].data, fteCurrent);
            }
            else {
                logError('Missing Current FTE - <a href="../?a=view_position&positionID=' + positionID + '" target="_blank">'+ data.title + '</a>');
            }

            for(i in data.subordinates) {
                if($.isNumeric(data.subordinates[i][11].data)) {
                    fteTotal = Math.round((parseFloat(data.subordinates[i][11].data) + fteTotal) * 100)/100;
                }
                else {
                    logError('Missing FTE Ceiling - <a href="../?a=view_position&positionID=' + data.subordinates[i].positionID + '" target="_blank">'+ data.subordinates[i].title + '</a>');
                }
                if($.isNumeric(data.subordinates[i][17].data)) {
                    fteCurrent = add(data.subordinates[i][17].data, fteCurrent);
                }
                else {
                    logError('Missing Current FTE - <a href="../?a=view_position&positionID=' + data.subordinates[i].positionID + '" target="_blank">'+ data.subordinates[i].title + '</a>');
                }

                if(data.subordinates[i].hasSubordinates == 1) {
                    if($.isNumeric(data.subordinates[i][11].data)) {
                        fteTotal = Math.round((fteTotal - parseFloat(data.subordinates[i][11].data)) * 100)/100;
                    }
                    if($.isNumeric(data.subordinates[i][17].data)) {
                        fteCurrent = Math.round((fteCurrent - parseFloat(data.subordinates[i][17].data)) * 100)/100;
                    }

                    countFTE(data.subordinates[i].positionID);
                }
            }
            $('#result').html('Total FTE: ' + fteTotal + '<br />Current FTE: ' + fteCurrent + '<br />Vacant FTE: ' + (Math.round((fteTotal - fteCurrent)*100)/100) );
    });
}

    posSel = new positionSelector('position');
    posSel.apiPath = '../api/?a=';
    posSel.rootPath = '../';
    posSel.optionEmployeeSearch = 1;
    posSel.initialize();
    posSel.setSelectHandler(function() {
        fteTotal = 0;
        fteCurrent = 0;
        $('#errors').html('');
        countFTE(posSel.selection);
    });

/* ]]> */
</script>

</div>

</body>
</html>
