<div id="history-slice">
</div>
<div>
<a id="prev" class="buttonNorm" style="float: left;cursor:pointer;"><- Prev</a>

<a id="next" class="buttonNorm" style="float:right;cursor:pointer;">Next -></a>
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
