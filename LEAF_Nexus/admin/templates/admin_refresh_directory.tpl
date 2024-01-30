<div id="toolbar" class="toolbar_right toolbar noprint" style="position: absolute; right: 2px"></div>

<div style="width: 99%;margin: 12px">
    <div id="info_refresh_container">
        <img id="info_refresh_icon"src="../dynicons/?img=emblem-notice.svg&w=64" style="float:left;margin-right: 12px" alt="" />
        <span id="info_refresh_message" style="font-size: 18px; font-weight: bold">The system is updating employees in the background. <br />Please feel free to navigate away from this page.<br />Individual employee information can be updated by searching for their name, and clicking on &quot;Refresh Employee&quot;.</span>
    </div>
</div>

<script type="text/javascript">

$(function() {
    var CSRFToken = '<!--{$CSRFToken}-->';

    $.ajax({
        type: 'POST',
        url: "../api/employee/refresh/batch",
        dataType: "json",
        data: {CSRFToken: CSRFToken},
        success: function (res) {

        },
        error: function(response) {
            $('#info_refresh_icon').attr('src', '../dynicons/?img=process-stop.svg&w=64');
            $('#info_refresh_message').text('LEAF obtained the error: ' + response);
        },
        cache: false
    });
});

</script>