<span style="font-size: 150%; font-style: italic; font-weight: bold" id="version"></span>
<br /><br />
<div style="line-height: 140%; width: 40%">
This software was developed by VA employees in an effort to streamline daily processes. 
<br /><br />
<img src="../libs/dynicons/?img=internet-mail.svg&amp;w=16" alt="email icon" /> Developer Contact: <a href="mailto:Michael.Gao@va.gov&amp;subject=LEAF:">Michael.Gao@va.gov</a>
</div>
<br /><br />

<table class="agenda">
    <tr>
        <td>Database version</td>
        <td><!--{$dbversion}--></td>
    </tr>
    <tr>
        <td>Server Timezone</td>
        <td><!--{date('T - e')}--></td>
    </tr>
    <tr>
        <td>Server Date</td>
        <td><!--{$smarty.now|date_format:"%A, %B %e, %Y"}--></td>
    </tr>
    <tr>
        <td>Server Time</td>
        <td><!--{$smarty.now|date_format:"%l:%M %p"}--></td>
    </tr>
</table>

<img style="position: absolute; bottom: 0px; right: 0px; width: 57%; z-index: -999" src="images/aboutlogo.png" alt="logo" />
<script type="text/javascript">

$(function() {
    $('#version').html($('#versionID').html());
});

</script>