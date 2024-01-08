<div id="toolbar" class="toolbar_right toolbar noprint" style="position: absolute; right: 2px"></div>

<div style="width: 85%">
    <span style="font-size: 18px; font-weight: bold">Refreshing Directory... This may take a few minutes.</span>
    <br /><br />

    <div id="groupList"></div>
</div>

<div id="editdialog1" style="visibility: hidden">
    <div>
        <div id="editxhr" style="width: 500px; height: 400px; overflow: auto">
            <div style="position: absolute; left: 10px"><button id="button_cancelchange"><img src="../dynicons/?img=process-stop.svg&amp;w=16" alt="" /> Cancel</button></div>
            <div style="border-bottom: 2px solid black; text-align: right"><br /><br />&nbsp;<!--<button id="button_save"><img src="../dynicons/?img=list-add.svg&amp;w=16" alt="" /> Add user</button>--></div><br />
            <label for="query">Search: </label><input id="query" type="text" /><div id="loadIndicator" style="visibility: hidden; float: right"><img src="../images/indicator.gif" alt="loading..." /></div>
            <br /><div id="results"></div>
        </div>
    </div>
</div>

<script type="text/javascript">
/* <![CDATA[ */

dojo.addOnLoad(function() {
    dojo.byId('groupList').innerHTML = '<div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Loading... <img src="../images/largespinner.gif" alt="" /></div>';

    dojo.xhrGet({
        url: "../scripts/maintenance.php",
        handleAs: "text",
        load: function(response, args) {
            dojo.byId('groupList').innerHTML = '<pre>' + response + '</pre>';
        },
        preventCache: true
    });
});

/* ]]> */
</script>
