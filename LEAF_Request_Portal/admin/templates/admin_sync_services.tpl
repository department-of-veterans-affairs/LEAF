<div class="leaf-center-content">

    <h2>Sync Services</h2>
    
    <div id="toolbar" class="toolbar_right toolbar noprint" style="position: absolute; right: 2px"></div>

    <div style="width: 85%">
        <span style="font-size: 18px; font-weight: bold">Syncing services from Org Chart...</span>
        <br /><br />

        <div id="groupList"></div>
    </div>

</div>


<script type="text/javascript">
/* <![CDATA[ */

$(function() {
    $('#groupList').html('<div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Loading... <img src="../images/largespinner.gif" alt="loading..." /></div>');

    $.ajax({
    	type: 'GET',
        url: "../scripts/updateServicesFromOrgChart.php",
        success: function(response) {
            $('#groupList').html('<pre>' + response + '</pre>');
        }
    });
});

/* ]]> */
</script>