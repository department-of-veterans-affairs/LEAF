<div id="history-slice"></div>

<div class="leaf-buttonBar">
    <button id="prev" class="usa-button usa-button--base leaf-btn-med">&lt; Prev</button>
    <button id="next" class="usa-button usa-button--base leaf-btn-med">Next &gt;</button>
</div>

<script type="text/javascript">
    //debugger;
    var page = 1;

    $.ajax({
        type: 'GET',
        url: 'ajaxIndex.php?a=gethistoryall&tz='+tz+'&type=<!--{$dataType}-->&gethistoryslice=1&page=1-->',
        dataType: 'text',
        success: function(res) {
            $('#history-slice').html(res);
            adjustPageButtons(page);
        },
        cache: false
    });

    $('#prev').on('click', function() {
        page = page - 1;

        $.ajax({
            type: 'GET',
            url: 'ajaxIndex.php?a=gethistoryall&tz='+tz+'&type=<!--{$dataType}-->&gethistoryslice=1&page=' + page,
            dataType: 'text',
            success: function(res) {
                $('#history-slice').html(res);
                adjustPageButtons(page);
            },
            cache: false
        });
    });

    $('#next').on('click', function() {
        page = page + 1;
        $.ajax({
            type: 'GET',
            url: 'ajaxIndex.php?a=gethistoryall&tz='+tz+'&type=<!--{$dataType}-->&gethistoryslice=1&page=' + page,
            dataType: 'text',
            success: function(res) {
                $('#history-slice').html(res);
                adjustPageButtons(page);
            },
            cache: false
        });
    });

    function adjustPageButtons(page) {
        if(<!--{$totalPages}--> < 2 || page == <!--{$totalPages}-->) {
            $('#next').hide();
        }
        else {
            $('#next').show();
        }
        if(page == 1) {
            $('#prev').hide();
        }
        else {
            $('#prev').show();
        }
    }

</script>
