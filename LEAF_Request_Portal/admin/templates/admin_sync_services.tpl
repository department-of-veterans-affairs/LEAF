<div class="leaf-center-content">

    <aside id="sideBar" class="sidenav-right"></aside>

    <aside class="sidenav"></aside>

     <main class="main-content">

        <h2>Sync Services</h2>

        <div id="toolbar" class="toolbar_right toolbar noprint" style="position: absolute; right: 2px"></div>

        <div>
            <span style="font-size: 18px; font-weight: bold">Syncing services from Org Chart...</span>
            <br /><br />

            <div id="groupList"></div>
        </div>

    </main>

</div>


<script type="text/javascript">
/* <![CDATA[ */

$(function() {
    $('#groupList').html('<div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Loading... for a large system this can take several seconds to minutes <img src="../images/largespinner.gif" alt="" /></div>');

    $.ajax({
    	type: 'GET',
        url: "../scripts/sync_services.php",
        success: function(response) {
            $('#groupList').html('<pre>' + response + '</pre>');
        }
    });
});

/* ]]> */
</script>