<!DOCTYPE html>
<html>

<head>
    <title>Organizational Chart Utility - Count FTE Ceiling</title>
    <style type="text/css" media="screen">
        @import <?= APP_JS_PATH . "/jquery/css/dcvamc/jquery-ui.custom.min.css" ?>;
        @import <?= APP_JS_PATH . "/jquery/chosen/chosen.min.css" ?>;
        @import "../css/style.css";
        @import "../css/editor.css";
        @import "../css/positionSelector.css";
    </style>
    <style type="text/css" media="print">
        @import "../css/printer.css";
        @import "../css/editor_printer.css";
    </style>
    <script type="text/javascript" src=<?= APP_JS_PATH . "/jquery/jquery.min.js" ?>></script>
    <script type="text/javascript" src=<?= APP_JS_PATH . "/jquery/jquery-ui.custom.min.js" ?>></script>
    <script type="text/javascript" src=<?= APP_JS_PATH . "/jquery/chosen/chosen.jquery.min.js" ?>></script>
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
            return Math.round((parseFloat(a) + parseFloat(b)) * 100) / 100;
        }

        function logError(error, errorLink, data) {
            // Escape the error message to prevent XSS attacks
            const sanitizedError = $('<div>').text(error).html();
            const sanitizedData = $('<div>').text(data).html();

            // Create an anchor tag with the sanitized error message and link
            const anchorTag = `${sanitizedError} <a href="${errorLink}" target="_blank">${sanitizedData}</a>`;

            // Append the anchor tag to the errors div
            $('#errors').append($('<div>').html(anchorTag));
        }

        var fteTotal = 0;
        var fteCurrent = 0;

        function countFTE(positionID) {
            $.get('../api/position/' + positionID,
                function(data) {
                    if ($.isNumeric(data[11].data)) {
                        fteTotal = Math.round((parseFloat(data[11].data) + fteTotal) * 100) / 100;
                    } else {
                        logError('Missing FTE Ceiling -','../?a=view_position&positionID=' + positionID , `${data.title}`);
                    }
                    if ($.isNumeric(data[17].data)) {
                        fteCurrent = add(data[17].data, fteCurrent);
                    } else {
                        logError('Missing Current FTE -','../?a=view_position&positionID=' + positionID , `${data.title}`);
                    }

                    for (i in data.subordinates) {
                        if ($.isNumeric(data.subordinates[i][11].data)) {
                            fteTotal = Math.round((parseFloat(data.subordinates[i][11].data) + fteTotal) * 100) / 100;
                        } else {
                            logError('Missing FTE Ceiling -','../?a=view_position&positionID=' + `${data.subordinates[i].positionID}`, `${data.subordinates[i].title}`);
                        }
                        if ($.isNumeric(data.subordinates[i][17].data)) {
                            fteCurrent = add(data.subordinates[i][17].data, fteCurrent);
                        } else {
                            logError('Missing Current FTE -','../?a=view_position&positionID=' + `${data.subordinates[i].positionID}`, `${data.subordinates[i].title}`);
                        }

                        if (data.subordinates[i].hasSubordinates == 1) {
                            if ($.isNumeric(data.subordinates[i][11].data)) {
                                fteTotal = Math.round((fteTotal - parseFloat(data.subordinates[i][11].data)) * 100) / 100;
                            }
                            if ($.isNumeric(data.subordinates[i][17].data)) {
                                fteCurrent = Math.round((fteCurrent - parseFloat(data.subordinates[i][17].data)) * 100) / 100;
                            }

                            countFTE(data.subordinates[i].positionID);
                        }
                    }
                    $('#result').html('Total FTE: ' + fteTotal + '<br />Current FTE: ' + fteCurrent + '<br />Vacant FTE: ' + (Math.round((fteTotal - fteCurrent) * 100) / 100));
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