<div><a href="?a=status&amp;recordID=<!--{$recordID|strip_tags}-->"><img src="../libs/dynicons/?img=printer.svg&amp;w=16" alt="Print status" /></a></div>
<div> <!-- main content -->
<span style="font-weight: bold; font-size: 16px">Notes for Record ID#: <!--{$recordID|sanitize}--></span>
<br />

<div style="padding: 2px">
<table class="agenda" id="maintable">
<thead>
<tr>
    <th>Timestamp</th>
    <th>Note</th>
    <th>User ID</th>
</tr>
</thead>

<!--{foreach from=$notes item=indicator}--><!--{strip}-->

<tr>
    <td>
        <!--{$indicator.timestamp|date_format:"%B %e, %Y. %l:%M %p"}-->
    </td>
    <td>
        <!--{$indicator.note|sanitize}-->
    </td>
    <td>
        <!--{$indicator.userID|sanitize}-->
    </td>
</tr>


<!--{/strip}--><!--{/foreach}-->

</div>

<div id="comment">
    <form name='note'>
        <textarea cols="45" rows="5">

        </textarea>
        <button id="submit_note">Submit Note</button>
    </form>
</div>

</div> <!-- close main content -->

<script>
    $('#submit_note').on('click')function({
        $.ajax({
            type: 'POST',
            url: 'api/note/<!--{$recordID|sanitize}-->/' ,
            data: {CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(response) {
                console.log(response);

            },
            error: function(response) {

            },
            cache: false
        });
    });
</script>