<div id="history-slice">
</div>

<a id="prev" class="buttonNorm" style="float: left;cursor:pointer;"><- Prev</a>

<a id="next" class="buttonNorm" style="float:right;cursor:pointer;">Next -></a>



<script type="text/javascript">
debugger;
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
        url: 'ajaxIndex.php?a=gethistory&tz='+tz+'&type=<!--{$dataType}-->&gethistoryslice=1&page=' + page,
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
        url: 'ajaxIndex.php?a=gethistory&tz='+tz+'&type=<!--{$dataType}-->&gethistoryslice=1&page=' + page,
        dataType: 'text',
        success: function(res) {
            $('#history-slice').html(res);
            adjustPageButtons(page);
        },
        cache: false
    });
});

function adjustPageButtons(page)
{
    if(<!--{$totalPages}--> < 2 || page == <!--{$totalPages}-->)
    {
        $('a#next').hide();
    }
    else
    {
        $('a#next').show();
    }

    if(page == 1)
    {
        $('a#prev').hide();
    }
    else
    {
        $('a#prev').show();
    }
}
</script>