<script type="text/javascript">
/* <![CDATA[ */

function importWebHR() {
	$('#progress').css('visibility', 'visible');

    $.ajax({
        url: "utils/importWebHR.php",
        type: "POST",
        data: {webHR: $('#webHR').val()},
        success: function(response) {
            $('#webHR').val('');
            $('#progress').css('visibility', 'hidden');
            alert(response);
        },
        error: function(jqXHR, status, error) {
            console.log("Error: " + error);
        },
        cache: false
    });
}

/* ]]> */
</script>

Instructions:<br />
<ol>
<li>Access WebHR Excel export</li>
<li>Copy/Paste contents of the WebHR Excel export file into the text area below</li>
<li>Click 'Import'</li>
</ol>


<textarea id="webHR" style="border: 1px solid black; width: 50%; height: 300px; padding: 4px"></textarea><br />
<button class="buttonNorm" onclick="importWebHR();" style="font-weight: bold; font-size: 120%"><img alt="" src="dynicons/?img=go-bottom.svg&w=32">Import</button><br />

<div id="progress" style="visibility: hidden; position: absolute; top: 80px; width: 100%; height: 90%; background-color: #e0e0e0; text-align: center; padding-top: 20%; font-size: 200%; color: black">Loading... <img src="images/indicator.gif" alt="" /></div>
