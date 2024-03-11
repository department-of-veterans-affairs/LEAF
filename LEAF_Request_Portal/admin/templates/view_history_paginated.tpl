<div id="history-slice"></div>

<div class="leaf-buttonBar">
    <button id="prev" class="usa-button usa-button--base leaf-btn-med leaf-float-left">Previous page</button>
    <button id="next" class="usa-button usa-button leaf-btn-med leaf-float-right">Next page</button>
</div>

<script type="text/javascript">
    var page = 1;
    var itemId = '<!--{$itemId}-->';

    $.ajax({
        type: 'GET',
        url: 'ajaxIndex.php?a=gethistory&type=<!--{$dataType}-->&gethistoryslice=1&page=1&id='+itemId,
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
            url: 'ajaxIndex.php?a=gethistory&type=<!--{$dataType}-->&gethistoryslice=1&page=' + page +'&id='+itemId,
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
            url: 'ajaxIndex.php?a=gethistory&type=<!--{$dataType}-->&gethistoryslice=1&id='+itemId+'&page=' + page,
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
        if($('#prev').css('display') === 'block') {
            $('#prev').focus();
        } else {
            $('.ui-dialog-titlebar-close').focus();
        }
    } else {
        $('#next').show();
    }

    if(page == 1) {
        $('#prev').hide();
        if($('#next').css('display') === 'block') {
            $('#next').focus();
        } else {
            $('.ui-dialog-titlebar-close').focus();
        }
    }
    else {
        $('#prev').show();
    }

}
</script>